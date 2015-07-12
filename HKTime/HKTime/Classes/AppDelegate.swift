//
//  AppDelegate.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/27/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import CoreData

var g_refreshingDevices = false


/**
The application delegate class. Responsible for the lifetime of the application.

:author:  TCSASSEMBLER
:version: 1.0
*/
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// the application window
    var window: UIWindow?

    var sleepPreventer : MMPDeepSleepPreventer!
    
    // Shared Instance: helper to access this singleton
    class var sharedInstance:AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    /**
    Application did finish launching
    
    :param: application the application
    :param: launchOptions the launch options
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.tintColor = UIColor.appIdentityColor()
        
        // First launch
        if !NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstLaunch")

        }
        
        sleepPreventer = MMPDeepSleepPreventer()
        sleepPreventer.startPreventSleep()
        
        // set up Local Notification
        if let options = launchOptions{
            
            // Do we have a value?
            let value = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
            
            if let notification = value {
                self.application(application, didReceiveLocalNotification: notification)
            }
        } else {
            askForNotificationPermissionForApplication(application)
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        let key1Value = notification.userInfo!["Key 1"] as? NSString
        let key2Value = notification.userInfo!["Key 2"] as? NSString
        
        if key1Value != nil && key2Value != nil{
            /* We got our notification */
            println("We got our notification")
            
        } else {
            /* This is not the notification that we composed */
            println("This is not the notification that we composed")
        }
        
    }
    
    func askForNotificationPermissionForApplication(application: UIApplication){
        // First ask the user if we are allowed to perform local notifications
        let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        
        application.registerUserNotificationSettings(settings)
        
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings){
        
        if notificationSettings.types == nil{
            println("The user did not allow us to send notification")
            return
        }
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        println("didEnterBackground")
        if g_refreshingDevices {
            g_HWControlHandler.stopRefreshDeviceInfo()
            g_refreshingDevices = false
        }
        
        g_wifiQuerying = false
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        println("didBecomeActive")
        if g_refreshingDevices {
            g_HWControlHandler.startRefreshDeviceInfo()
        }
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.topcoder.PageApp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("HKTime", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HKTime.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}

