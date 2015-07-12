//
//  NowPlayingVC.swift
//  HWSimplePlayer
//
//  Created by Seonman Kim on 12/31/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit
import AVFoundation

class NowPlayingVC: UIViewController, HKWPlayerEventHandlerDelegate {
    var row = 0
    var section = 0
    var songTitle = ""
    var nsWavPath = ""
    var viewLoadByCellSelection = false
    var songSelectionTVC: SongSelectionTVC!
    var curVolume:Int = 50
    var songUrl = ""
    var serverUrl = ""

    var g_alert: UIAlertController!

    @IBOutlet var labelSongTitle: UILabel!
    @IBOutlet var btnPlayStop: UIButton!
    @IBOutlet var labelAverageVolume: UILabel!
    @IBOutlet var btnVolumeDown: UIButton!
    @IBOutlet var btnVolumeUp: UIButton!
    @IBOutlet var labelStatus: UILabel!
    
    @IBAction func playOrStop(sender: UIButton) {
        if HKWControlHandler.sharedInstance().isPlaying() {
            HKWControlHandler.sharedInstance().pause()
            labelStatus.text = "Play Stopped"

            btnPlayStop.setTitle("Play", forState: UIControlState.Normal)

        }
        else {
            playCurrentTitle()
            labelStatus.text = "Now Playing"
        }
    }
    
    @IBAction func volumeUp(sender: UIButton) {
        curVolume += 5
        
        if curVolume > 50 {
            curVolume = 50
        }
        HKWControlHandler.sharedInstance().setVolume(curVolume)

        labelAverageVolume.text = "Volume: \(curVolume)"

    }
    @IBAction func volumeDown(sender: UIButton) {
        curVolume -= 5
        
        if curVolume < 0 {
            curVolume = 0
        }

        HKWControlHandler.sharedInstance().setVolume(curVolume)
        labelAverageVolume.text = "Volume: \(curVolume)"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self

        labelSongTitle.text = songTitle
        curVolume = HKWControlHandler.sharedInstance().getVolume()
        labelAverageVolume.text = "Volume: \(curVolume)"
        
        if viewLoadByCellSelection {
            playCurrentTitle()
            
        } else {
            if HKWControlHandler.sharedInstance().isPlaying() {
                btnPlayStop.setTitle("Stop", forState: UIControlState.Normal)
                labelStatus.text = "Now Playing"
            }
            else {
                btnPlayStop.setTitle("Play", forState: UIControlState.Normal)
                labelStatus.text = "Play Stopped"
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playCurrentTitle() {
        
        // just to be sure that there is no running playback
        HKWControlHandler.sharedInstance().stop()
        
        println("nsWavPath: \(nsWavPath)")
        if section == 0 {
            if HKWControlHandler.sharedInstance().playWAV(nsWavPath) {
                // now playing, so change the icon to "STOP"
                btnPlayStop.setTitle("Stop", forState: UIControlState.Normal)
            }
        } else if section == 1 {
            let assetUrl = NSURL(fileURLWithPath: nsWavPath)
            
            if HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: songTitle, resumeFlag: false) {
                // now playing, so change the icon to "STOP"
                btnPlayStop.setTitle("Stop", forState: UIControlState.Normal)
            }
        } else {
            playStreaming()
        }
        songSelectionTVC.bbiNowPlaying.enabled = true
    }
    
    func playStreaming() {
        HKWControlHandler.sharedInstance().playStreamingMedia(songUrl, withCallback: {(bool result) -> Void in
            if result == false {
                println("playStreamingMedia: failed")
                self.btnPlayStop.selected = false
                
                self.g_alert = UIAlertController(title: "Warning", message: "Playing streaming media failed. Please check the Internet connection or check if the meida URL is correct.", preferredStyle: .Alert)
                self.g_alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(self.g_alert, animated: true, completion: nil)
            } else {
                println("playStreamingMedia: successful")
            }
        })
    }
    
    func hkwPlayEnded() {
        btnPlayStop.setTitle("Play", forState: UIControlState.Normal)
        songSelectionTVC.bbiNowPlaying.enabled = false
    }

    func hkwDeviceVolumeChanged(deviceId: Int64, deviceVolume: Int, withAverageVolume avgVolume: Int) {
        println("avgVolume: \(avgVolume)")
        curVolume = avgVolume
    }
}
