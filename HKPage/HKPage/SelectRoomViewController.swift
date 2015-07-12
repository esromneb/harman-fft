//
//  SelectRoomViewController.swift
//  HKPage
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//


import UIKit

let roomNameList = [kGroupNotAssigned, "Balcony", "Basement", "Bathroom", "Bedroom", "Deck", "Dining Room", "Garage", "Gargen", "Hallway", "Kitchen", "Living Room", "Loft", "Lounge", "Patio", "Pool", "Study"]
let roomIconList = ["roomicon_default", "room_balcony", "room_basement", "room_bathroom", "room_bedroom", "room_deck", "room_diner", "room_garage", "room_garden", "room_hallway", "room_kitchen", "room_livingroom", "room_loft", "room_lounge", "room_patio", "room_pool", "room_studyroom"]

func getGroupIconName(groupName: String) -> String {
    var index = -1
    for var i = 0; i < roomNameList.count; i++ {
        if groupName == roomNameList[i] {
            index = i
            break
        }
    }
    if index == -1 {
        return ""
    } else {
        return roomIconList[index];
    }
}

class SelectRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    /// the tableView
    @IBOutlet weak var tableView: UITableView!

    var roomName : String?
    var deviceInfo : DeviceInfo!
    
    var editSpeakerVC : EditSpeakerViewController!
    
    /// selected row
    var selectedRow: Int?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*!
    Setup navigation items for this page
    */
    func setupNavigationItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveButtonDidPress:")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 7/255, green: 158/255, blue: 217/255, alpha: 1.0)
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    
    /*!
    Action on "Save" button did press
    
    :param: sender the sender object
    */
    func saveButtonDidPress(sender: AnyObject) {
        if roomName == kGroupNotAssigned {
            HKWControlHandler.sharedInstance().removeDeviceFromGroup(deviceInfo.deviceId)
            editSpeakerVC.roomLabel.text = kGroupNotAssigned
        }
        else {
            HKWControlHandler.sharedInstance().setDeviceGroupName(deviceInfo.deviceId, groupName:roomName)
            editSpeakerVC.roomLabel.text = roomName
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomNameList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SelectRoomCell") as! RoomSelectionTableViewCell
        

        var selected = false
        if roomName == roomNameList[indexPath.row] {
            selected = true
        } else {
            selected = false
        }
        cell.setItem(roomIconList[indexPath.row], title: roomNameList[indexPath.row], selected: selected)
        
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
        var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? RoomSelectionTableViewCell
        if cell != nil {
            cell!.selectIcon.hidden = false
        }
        
        roomName = cell?.titleLabel.text
        
    }
    
    /*!
    Unselect all items
    */
    func unselectAllItems() {
        
        // Set all visible cells to unselected
        for visibleCell in tableView.visibleCells() {
            var selectCell = visibleCell as! RoomSelectionTableViewCell
            selectCell.selectIcon.hidden = true
        }
    }

}
