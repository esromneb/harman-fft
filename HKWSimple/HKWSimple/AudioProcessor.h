//
//  AudioProcessor.h
//  MicInput
//
//  Created by Stefan Popp on 21.09.11.
//  Copyright 2011 http://http://www.stefanpopp.de/2011/capture-iphone-microphone//2011/capture-iphone-microphone/ . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import </Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.4.sdk/System/Library/Frameworks/Accelerate.framework/Headers/Accelerate.h>
// return max value for given values
#define max(a, b) (((a) > (b)) ? (a) : (b))
// return min value for given values
#define min(a, b) (((a) < (b)) ? (a) : (b))

#define kOutputBus 0
#define kInputBus 1

// our default sample rate
#define SAMPLE_RATE 44100.00

@interface AudioProcessor : NSObject
{
    // Audio unit
    AudioComponentInstance audioUnit;
    
    // Audio buffers
    AudioBuffer audioBuffer;
    
    // gain
    float gain;
    
    FFTSetup      _FFTSetup;
    
    float _mags[512];
    float updates;
}

@property (readonly) AudioBuffer audioBuffer;
@property (readonly) AudioComponentInstance audioUnit;
@property (nonatomic) float gain;
@property (readonly) float *mags;
@property (readonly) int updates;

//@property(readonly) float *doubleDigits;

typedef struct OpaqueFFTSetup * FFTSetup;

-(AudioProcessor*)init;

-(void)initializeAudio;
-(void)processBuffer: (AudioBufferList*) audioBufferList;

// control object
-(void)start;
-(void)stop;
-(int)running;

// gain
-(void)setGain:(float)gainValue;
-(float)getGain;


// error managment
-(void)hasError:(int)statusCode:(char*)file:(int)line;

@end
