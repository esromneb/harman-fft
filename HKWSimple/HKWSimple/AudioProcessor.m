//
//  AudioProcessor.m
//  MicInput
//
//  Created by Stefan Popp on 21.09.11.
//  Copyright 2011 http://www.stefanpopp.de/2011/capture-iphone-microphone/ . All rights reserved.
//

#import "AudioProcessor.h"

#pragma mark Recording callback



int isRunning = 0;

COMPLEX_SPLIT _A;
FFTSetup      _FFTSetup;
BOOL          _isFFTSetup;
vDSP_Length   _log2n;
float mags[512];
int updates;

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // the data gets rendered here
    AudioBuffer buffer;
    
    // a variable where we check the status
    OSStatus status;
    
    /**
     This is the reference to the object who owns the callback.
     */
    AudioProcessor *audioProcessor = (AudioProcessor*) inRefCon;
    
    /**
     on this point we define the number of channels, which is mono
     for the iphone. the number of frames is usally 512 or 1024.
     */
    buffer.mDataByteSize = inNumberFrames * 2; // sample size
    buffer.mNumberChannels = 1; // one channel
    buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
    
    // we put our buffer into a bufferlist array for rendering
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    // render input and check for error
    status = AudioUnitRender([audioProcessor audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    [audioProcessor hasError:status:__FILE__:__LINE__];
    
    // process the bufferlist in the audio processor
    [audioProcessor processBuffer:&bufferList];
    
    // clean up the buffer
    free(bufferList.mBuffers[0].mData);
    
    return noErr;
}

#pragma mark Playback callback

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    
    /**
     This is the reference to the object who owns the callback.
     */
    AudioProcessor *audioProcessor = (AudioProcessor*) inRefCon;
    
    // iterate over incoming stream an copy to output stream
    for (int i=0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer buffer = ioData->mBuffers[i];
        
        // find minimum size
        UInt32 size = min(buffer.mDataByteSize, [audioProcessor audioBuffer].mDataByteSize);
        
        // copy buffer to audio buffer which gets played after function return
        memcpy(buffer.mData, [audioProcessor audioBuffer].mData, size);
        
        // set data size
        buffer.mDataByteSize = size;
    }
    return noErr;
}

#pragma mark objective-c class

@implementation AudioProcessor
@synthesize audioUnit, audioBuffer, gain;

- (float *)mags
{
    return mags;
}

- (int)updates
{
    return updates;
}


-(AudioProcessor*)init
{
    self = [super init];
    if (self) {
        gain = 0;
        [self initializeAudio];
    }
    
    isRunning = 0;
    updates = 0;
    
    return self;
}

-(void)initializeAudio
{
    OSStatus status;
    
    // We define the audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output; // we want to ouput
    desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
    desc.componentFlags = 0; // must be zero
    desc.componentFlagsMask = 0; // must be zero
    desc.componentManufacturer = kAudioUnitManufacturer_Apple; // select provider
    
    // find the AU component by description
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // create audio unit by component
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    [self hasError:status:__FILE__:__LINE__];
    
    // define that we want record io on the input bus
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO, // use io
                                  kAudioUnitScope_Input, // scope to input
                                  kInputBus, // select input bus (1)
                                  &flag, // set flag
                                  sizeof(flag));
    [self hasError:status:__FILE__:__LINE__];
    
    // define that we want play on io on the output bus
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO, // use io
                                  kAudioUnitScope_Output, // scope to output
                                  kOutputBus, // select output bus (0)
                                  &flag, // set flag
                                  sizeof(flag));
    [self hasError:status:__FILE__:__LINE__];
    
    /*
     We need to specifie our format on which we want to work.
     We use Linear PCM cause its uncompressed and we work on raw data.
     for more informations check.
     
     We want 16 bits, 2 bytes per packet/frames at 44khz
     */
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= SAMPLE_RATE;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;
    
    
    
    // set the format on the output stream
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    
    [self hasError:status:__FILE__:__LINE__];
    
    // set the format on the input stream
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    [self hasError:status:__FILE__:__LINE__];
    
    
    
    /**
     We need to define a callback structure which holds
     a pointer to the recordingCallback and a reference to
     the audio processor object
     */
    AURenderCallbackStruct callbackStruct;
    
    // set recording callback
    callbackStruct.inputProc = recordingCallback; // recordingCallback pointer
    callbackStruct.inputProcRefCon = self;
    
    // set input callback to recording callback on the input bus
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
    [self hasError:status:__FILE__:__LINE__];
    
    /*
     We do the same on the output stream to hear what is coming
     from the input stream
     */
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = self;
    
    // set playbackCallback as callback on our renderer for the output bus
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    [self hasError:status:__FILE__:__LINE__];
    
    // reset flag to 0
    flag = 0;
    
    /*
     we need to tell the audio unit to allocate the render buffer,
     that we can directly write into it.
     */
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    
    /*
     we set the number of channels to mono and allocate our block size to
     1024 bytes.
     */
    audioBuffer.mNumberChannels = 1;
    audioBuffer.mDataByteSize = 512 * 2;
    audioBuffer.mData = malloc( 512 * 2 );
    
    // Initialize the Audio Unit and cross fingers =)
    status = AudioUnitInitialize(audioUnit);
    [self hasError:status:__FILE__:__LINE__];
    
    NSLog(@"Started");
    
    
    int bufferSize = 1024;
    
    _log2n = log2f(bufferSize);
    
    float dummy[bufferSize*2];
    
    // setup fft
    
    _FFTSetup = vDSP_create_fftsetup(10, FFT_RADIX2);

//    _FFTSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
//    
//    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Populate *window with the values for a hamming window function
    float *window = (float *)malloc(sizeof(float)*bufferSize);
    vDSP_hamm_window(window, bufferSize, 0);
    // Window the samples
    vDSP_vmul(dummy, 1, window, 1, dummy, 1, bufferSize);
    free(window);
    
    // Define complex buffer
    _A.realp = (float *) malloc(nOver2*sizeof(float));
    _A.imagp = (float *) malloc(nOver2*sizeof(float));
  
    
    
    typedef struct OpaqueFFTSetup * FFTSetup;
}

#pragma mark controll stream

-(void)start;
{
    // start the audio unit. You should hear something, hopefully :)
    OSStatus status = AudioOutputUnitStart(audioUnit);
    [self hasError:status:__FILE__:__LINE__];
    isRunning = 1;
    NSLog(@"starting mic");
}
-(void)stop;
{
    // stop the audio unit
    OSStatus status = AudioOutputUnitStop(audioUnit);
    [self hasError:status:__FILE__:__LINE__];
    isRunning = 0;
    NSLog(@"ending mic");
}

-(int)running
{
    return isRunning;
}


-(void)setGain:(float)gainValue
{
    gain = gainValue;
}

-(float)getGain
{
    return gain;
}



#pragma mark processing

-(void)processBuffer: (AudioBufferList*) audioBufferList
{
    static int called = 0;
//    NSLog(@"cnt %d", called++);
    called++;
    
    AudioBuffer sourceBuffer = audioBufferList->mBuffers[0];
    
    // we check here if the input data byte size has changed
    if (audioBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
        // clear old buffer
        free(audioBuffer.mData);
        // assing new byte size and allocate them on mData
        audioBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
        audioBuffer.mData = malloc(sourceBuffer.mDataByteSize);
    }
    
    /**
     Here we modify the raw data buffer now.
     In my example this is a simple input volume gain.
     iOS 5 has this on board now, but as example quite good.
     */
    SInt16 *editBuffer = audioBufferList->mBuffers[0].mData;
    
    int count = (audioBufferList->mBuffers[0].mDataByteSize / 2);
    
    
int    _log2n = 10;
    int bufferSize = 1024;
     int nOver2 = bufferSize/2;
    
    
    float data[bufferSize];
//    float _A[bufferSize*2];
    
    
    
    
    // loop over every packet
    for (int nb = 0; nb < count; nb++) {
  

        data[nb] = (float)editBuffer[nb];
//        data[(nb*2)+1] = 0.0;
        
                    editBuffer[nb] = 0;
        
        //}
    }
    
//    
//    
//    
//    // Pack samples:
//    // C(re) -> A[n], C(im) -> A[n+1]
    vDSP_ctoz((COMPLEX*)data, 2, &_A, 1, nOver2);
//
//    // Perform a forward FFT using fftSetup and A
//    // Results are returned in A
    vDSP_fft_zrip(_FFTSetup, &_A, 1, _log2n, FFT_FORWARD);
//
//    // Convert COMPLEX_SPLIT A result to magnitudes
//    float amp[nOver2];
    float maxMag = 0;

    for(int i=0; i<nOver2; i++) {
        // Calculate the magnitude
        float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
//        maxMag = mag > maxMag ? mag : maxMag;
        mags[i] = mag;
    }
    

    updates++;
    
    
    // copy incoming audio data to the audio buffer
    memcpy(audioBuffer.mData, audioBufferList->mBuffers[0].mData, audioBufferList->mBuffers[0].mDataByteSize);
}

#pragma mark Error handling

-(void)hasError:(int)statusCode:(char*)file:(int)line 
{
    if (statusCode) {
        printf("Error Code responded %d in file %s on line %d\n", statusCode, file, line);
        exit(-1);
    }
}


@end
