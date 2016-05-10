//
//  AppDelegate.swift
//  Messenger
//
//  Created by 虞子轩 on 15/11/30.
//  Copyright (c) 2015年 Zixuan. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = navColor
     //   UITabBar.appearance().barTintColor = navColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: navTextColor]
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().tintColor = navTextColor
        
        Initialization().launch()
        Clockwork().Synchronize()
        
        Parse.setApplicationId(appId, clientKey: clientKey)
        PFFacebookUtils.initializeFacebook()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        // check if user is logged in
        
        if PFUser.currentUser() != nil && PFUser.currentUser().isAuthenticated() {
            
        } else {
            let loginvc = storyb.instantiateViewControllerWithIdentifier("loginvc") as! LoginViewController
            window?.rootViewController = loginvc
            
        }
        
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") { // uis 8
            /*let notificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)*/
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            
        } else {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge , .Sound], categories: nil))
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        
        
        return true
    }
    
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        AudioServicesPlayAlertSound(1110)
        
        NSNotificationCenter.defaultCenter().postNotificationName("displayMessage", object: userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadMessages", object: nil)
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication, withSession: PFFacebookUtils.session())
    }
    
    
    
    
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Initialization().quit()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        Initialization().launch()
        Clockwork().Synchronize()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Initialization().quit()
    }
    
    
}
