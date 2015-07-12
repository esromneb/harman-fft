//
//  VoiceRecorder.swift
//  HKPage
//
//  Created by Seonman Kim on 2/9/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import AVFoundation


class VoiceRecorder: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate, HKWPlayerEventHandlerDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    var viewController: UIViewController!
    var alert: UIAlertController!
    
    static var delegateInitialized = false

    override init() {
        super.init()
        
    }
    
    
    // Mark: Record Voice
    
    func startRecordingVoice() {
        /* Ask for permission to see if we can record audio */
        var error: NSError?
        let session = AVAudioSession.sharedInstance()
        
        if session.setCategory(AVAudioSessionCategoryPlayAndRecord,
            withOptions: .DuckOthers,
            error: &error){
                
                if session.setActive(true, error: nil){
                    println("Successfully activated the audio session")
                    
                    session.requestRecordPermission{[weak self](allowed: Bool) in
                        
                        if allowed{
                            self!.startRecordingAudio()
                        } else {
                            println("We don't have permission to record audio");
                        }
                        
                    }
                } else {
                    println("Could not activate the audio session")
                }
                
        } else {
            
            if let theError = error{
                println("An error occurred in setting the audio " +
                    "session category. Error = \(theError)")
            }
        }
        
    }
    
    func stopRecodingVoice() {
        if audioRecorder != nil {
            audioRecorder!.stop()
            audioRecorder = nil
        }
    }
    
    func startRecordingAudio(){
        
        var error: NSError?
        
        let audioRecordingURL = self.audioRecordingPath()
        
        audioRecorder = AVAudioRecorder(URL: audioRecordingURL,
            settings: audioRecordingSettings() as [NSObject : AnyObject],
            error: &error)
        
        if let recorder = audioRecorder {
            
            recorder.delegate = self
            /* Prepare the recorder and then start the recording */
            
            if recorder.prepareToRecord() && recorder.record(){
                
                println("Successfully started to record.")
                
            } else {
                println("Failed to record.")
                audioRecorder = nil
            }
            
        } else {
            println("Failed to create an instance of the audio recorder")
        }
        
    }
    
    func audioRecordingPath() -> NSURL{
        
        let fileManager = NSFileManager()
        
        let documentsFolderUrl = fileManager.URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask,
            appropriateForURL: nil,
            create: false,
            error: nil)
        
        return documentsFolderUrl!.URLByAppendingPathComponent("Recording.wav")
        
    }
    
    func audioRecordingSettings() -> NSDictionary{
        /*
        return [
        AVFormatIDKey : kAudioFormatMPEG4AAC as NSNumber,
        //   AVFormatIDKey : kAudioFormatLinearPCM as NSNumber,
        //        AVSampleRateKey : 44100.1 as NSNumber,
        
        AVSampleRateKey : 16000.0 as NSNumber,
        
        AVNumberOfChannelsKey : 1 as NSNumber,
        AVEncoderAudioQualityKey : AVAudioQuality.Medium.rawValue as NSNumber
        ]
        */
        
        return [
            AVFormatIDKey : kAudioFormatLinearPCM as NSNumber,
            AVSampleRateKey : 44100.0 as NSNumber,
            AVNumberOfChannelsKey : 2 as NSNumber,
            AVLinearPCMBitDepthKey : 16 as NSNumber,
            AVLinearPCMIsBigEndianKey : 1 as NSNumber,
            AVLinearPCMIsFloatKey : 0 as NSNumber,
            AVEncoderAudioQualityKey : AVAudioQuality.High.rawValue as NSNumber
            
        ]
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        /* The audio session is deactivated here */
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!, withOptions flags: Int) {
        if flags == AVAudioSessionInterruptionFlags_ShouldResume{
            player.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool){
        
        if flag{
            println("Audio player stopped correctly")
        } else {
            println("Audio player did not stop correctly")
        }
        
        audioPlayer = nil
        
    }
    
    
    func stopPlayingVoice() {

        HKWControlHandler.sharedInstance().stop()
        
    }

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool){
        
        if flag{
            
            println("Successfully stopped the audio recording process")
            
            var wavPath = audioRecordingPath().path!
            println("wavPath: \(wavPath)")
            

            if !HKWControlHandler.sharedInstance().isInitialized() {
                return
            }
            HKWControlHandler.sharedInstance().stop()
            
            HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self

            
            HKWControlHandler.sharedInstance().playCAF(audioRecordingPath(), songName: "Recording.wav", resumeFlag: false)
            
            alert = UIAlertController(title: "Now Playing", message: "Your voice is being played.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "STOP", style: UIAlertActionStyle.Default, handler: { (uiAlertAction: UIAlertAction!) -> Void in
                self.stopPlayingVoice()
            }))
            
            viewController.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            println("Stopping the audio recording failed")
        }
        
        /* Here we don't need the audio recorder anymore */
        self.audioRecorder = nil;
        
    }
    
    // MARK: - HKWEventHandlerDelegate
    func hkwPlayEnded() {
        println("playEnded()")
        if self.alert != nil {
            self.alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = nil
    }
   
    func hkwPlaybackStateChanged(playState: Int) {
        println("playStateChanged: \(playState)")
    }
}
