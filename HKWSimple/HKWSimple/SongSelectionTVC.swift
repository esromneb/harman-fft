//
//  SongSelectionTVC.swift
//  HWSimplePlayer
//
//  Created by Seonman Kim on 12/31/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit

class SongSelectionTVC: UITableViewController {
    var g_wavFiles = [String]()
    var g_mp3Files = [String]()
    var curSection = 0
    var curRow = 0
    
    let serverUrlPrefix = "http://seonman.github.io/music/";
    
    var songList = ["ec-faith.wav", "hyolyn.mp3"]

    @IBOutlet var bbiNowPlaying: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var bundleRoot = NSBundle.mainBundle().bundlePath
        var dirContents: NSArray = NSFileManager.defaultManager().contentsOfDirectoryAtPath(bundleRoot, error: nil)!
        var fltr: NSPredicate = NSPredicate(format: "self ENDSWITH '.wav'")
        g_wavFiles = dirContents.filteredArrayUsingPredicate(fltr) as! [String]
        
        for var i = 0; i < g_wavFiles.count; i++ {
            println("wav file: \(g_wavFiles[i])")
        }
        
        var fltr2: NSPredicate = NSPredicate(format: "self ENDSWITH '.mp3'")
        g_mp3Files = dirContents.filteredArrayUsingPredicate(fltr2) as! [String]
        
        for var i = 0; i < g_mp3Files.count; i++ {
            println("mp3 file: \(g_mp3Files[i])")
        }
        
        bbiNowPlaying.enabled = HKWControlHandler.sharedInstance().isPlaying()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return g_wavFiles.count
        } else if section == 1 {
            return g_mp3Files.count
        } else if section == 2 {
            return songList.count
        }else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongTitle_Cell", forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.section == 0 {
            cell.textLabel?.text = g_wavFiles[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel?.text = g_mp3Files[indexPath.row]
        } else {
            cell.textLabel?.text = songList[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "WAV file"
        } else if section == 1 {
            return "MP3 file"

        }else {
            return "Web Streaming"
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Song_Cell" {
            let section = self.tableView.indexPathForSelectedRow()?.section
            curSection = section!
            let row = self.tableView.indexPathForSelectedRow()?.row
            curRow = row!
            
            let destTVC:NowPlayingVC = segue.destinationViewController as! NowPlayingVC
            destTVC.section = curSection
            destTVC.row = curRow
            if curSection == 0 {
                destTVC.songTitle = g_wavFiles[curRow]
            } else if curSection == 1 {
                destTVC.songTitle = g_mp3Files[curRow]
            } else {
                destTVC.songTitle = songList[curRow]
                destTVC.songUrl = serverUrlPrefix + songList[curRow]
                destTVC.serverUrl = serverUrlPrefix
            }
            
            destTVC.viewLoadByCellSelection = true
            destTVC.nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(destTVC.songTitle)
            destTVC.songSelectionTVC = self

        }

        else if segue.identifier == "NowPlaying_BBI" {
            let destTVC:NowPlayingVC = segue.destinationViewController as! NowPlayingVC
            
            if curSection == 0 {
                destTVC.songTitle = g_wavFiles[curRow]
            } else if curSection == 1 {
                destTVC.songTitle = g_mp3Files[curRow]
            } else {
                destTVC.songTitle = songList[curRow]
                destTVC.songUrl = serverUrlPrefix + songList[curRow]
                destTVC.serverUrl = serverUrlPrefix
            }
            
            destTVC.viewLoadByCellSelection = false
            destTVC.nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(destTVC.songTitle)
            destTVC.songSelectionTVC = self

        }
    }

}
