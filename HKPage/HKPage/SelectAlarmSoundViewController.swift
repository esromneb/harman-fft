//
//  SelectAlarmSoundViewController.swift
//  HKPage
//
//  Created by Seonman Kim on 2/16/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import AVFoundation

let alarmSoundNameList = ["Industrial Alert", "Red Alert", "Siren", "Tornado Siren"]
let alarmSoundFileList = ["Industrial Alarm-30s.mp3", "Red Alert-30s.mp3", "Siren-28s.mp3", "Tornado Siren-45s.mp3"]

class SelectAlarmSoundViewController: UIViewController, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer!
    
    /// the tableView
    @IBOutlet weak var tableView: UITableView!
    
    var alarmSoundName : String?
    var deviceInfo : DeviceInfo!
    
    var g_audioPlaying = false
        
    /// selected row
    var selectedRow: Int?
    
    // MARK: UIViewController
    
    class func getAlarmSoundFile(soundName: String) -> String {
        for var i = 0; i < alarmSoundNameList.count; i++ {
            if alarmSoundNameList[i] == soundName {
                return alarmSoundFileList[i]
            }
        }
        
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var defaults = NSUserDefaults.standardUserDefaults()

        if let tempName = defaults.stringForKey("alarmSound") {
            alarmSoundName = tempName
        }
        
        setupNavigation()
        setupNavigationItems()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonDidPress(sender: AnyObject) {
        self.menuContainerViewController?.toggleMenu(true)
    }
    
    func setupNavigation() {        
        var titleLabel = UILabel(frame: CGRectMake(0, 10, 300, 20))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "MyriadPro-Regular", size: 18.0)
        titleLabel.text = "Alarm Sound"
        self.navigationItem.titleView = titleLabel
        
        // Change background using image to achieve the same appearence with the design
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_bar_image"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    
    /*!
    Setup navigation items for this page
    */
    func setupNavigationItems() {

        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 7/255, green: 158/255, blue: 217/255, alpha: 1.0)
        self.navigationController?.navigationBar.topItem?.title = "Hello"
    }
    
    
    // MARK: UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmSoundNameList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SelectAlarmSoundCell") as! AlarmSoundSelectionTableViewCell
        
        var selected = false
        if alarmSoundName == alarmSoundNameList[indexPath.row] {
            selected = true
        } else {
            selected = false
        }
        cell.setItem(alarmSoundNameList[indexPath.row], selected: selected)
        
        return cell
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        unselectAllItems()
        selectItemAtRow(indexPath.row)
    }
    
    /*!
    Select item at a row
    
    :param: row row to be selected
    */
    func selectItemAtRow(row: Int) {
        var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? AlarmSoundSelectionTableViewCell
        if cell != nil {
            cell!.selectIcon.hidden = false
        }
        
        if alarmSoundName == cell?.titleLabel.text {
            if g_audioPlaying {
                audioPlayer.stop()
                return
            }
        }
        
        alarmSoundName = cell?.titleLabel.text
        
        // Save alarm sound name
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(alarmSoundName, forKey: "alarmSound")
        
        var alertSoundFile = SelectAlarmSoundViewController.getAlarmSoundFile(alarmSoundName!)
        
        var nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(alertSoundFile)
        var assetUrl = NSURL(fileURLWithPath: nsWavPath)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var error: NSError?
            
            self.audioPlayer = AVAudioPlayer(contentsOfURL: assetUrl, error: &error)
            
            if let player = self.audioPlayer {
                player.delegate = self
                
                if player.prepareToPlay() && player.play() {
                    println("Successfully started playing")
                    self.g_audioPlaying = true
                } else {
                    println("failed to play")
                    self.g_audioPlaying = false
                }
            } else {
                println("failed to instantiate AVAudioPlayer")
            }
        })
    }
    
    /*!
    Unselect all items
    */
    func unselectAllItems() {
        
        // Set all visible cells to unselected
        for visibleCell in tableView.visibleCells() {
            var selectCell = visibleCell as! AlarmSoundSelectionTableViewCell
            selectCell.selectIcon.hidden = true
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("Finished playing the alarm")
    }

}
