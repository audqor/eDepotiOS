//
//  AppDelegate.swift
//  edepotMobile
//
//  Created by nocson on 2018. 8. 9..
//  Copyright © 2018년 nocson. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var tokenKey = String()
    var mainView = MainView()
    var isAlert = false
    
    //앱이 현재 화면에서 실행되고 있을 때
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
        
        
    }
    
    //앱은 꺼져있는데 푸시를 받고 해당 푸시를 클릭했을 때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
                if err != nil{
                    
                } else {
                    
                    UNUserNotificationCenter.current().delegate = self
                    Messaging.messaging().delegate = self
                    
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                    FirebaseApp.configure()
                }
                
            }
        }else{
            let notificationSettings = UIUserNotificationSettings(types:[.alert,.sound,.badge],categories:nil)
            application.registerUserNotificationSettings(notificationSettings)
            application.registerForRemoteNotifications()
            application.delegate = self
        }
        let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
        
        if remoteNotif != nil {
            if (remoteNotif!["aps" as NSString] as? NSDictionary) != nil {
                isAlert = true
            }
        }
        else{
            
        }
        
        return true
        
        
        
        
        //APNS 사용. 기존 코드
//        if #available(iOS 10.0, *){
//            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
//                if(error != nil){
//                    print("");
//                    return
//                 }
//                if granted{
//                    application.registerForRemoteNotifications()
//                    UNUserNotificationCenter.current().delegate = self
//
//                }
//                else{
//                    print("")
//                }
//
//
//            }
//        }else{
//
//            let notificationSettings = UIUserNotificationSettings(types:[.alert,.sound,.badge],categories:nil)
//            application.registerUserNotificationSettings(notificationSettings)
//            application.registerForRemoteNotifications()
//            application.delegate = self
//        }
//
//
//        let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
//        if remoteNotif != nil {
//            if (remoteNotif!["aps" as NSString] as? NSDictionary) != nil {
//                isAlert = true
//            }
//        }
//        else{
//
//        }
//
//
//        return true
    }
    
    func ConnectToFCM() {
        
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    
    
    
    
    //앱은 꺼져있지만 완전히 종료되지 않고 백그라운드에서 실행중 일때
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //푸시를 클릭했을 때
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier{
            let userInfo = response.notification.request.content.userInfo

            
            if let aps = userInfo[AnyHashable("aps")]{
               
                 let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
//                앱 종료된 시점에서 타게되면 crash되기 떄문에 방어코드
                if(!isAlert){
                    appDelegate.mainView.sendWebURL(url: "a")
                }
            }
//            if let aps = userInfo["aps"] as? NSDictionary {
//
//                let strURL: String? = (aps["title"] as! String?)
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//                //앱 종료된 시점에서 타게되면 crash되기 떄문에 방어코드
//                if(!isAlert){
//                    appDelegate.mainView.sendWebURL(url: strURL!)
//                }
//
//            }
//            else{
//
//            }
        }
        
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        let state: UIApplicationState = UIApplication.shared.applicationState
        
        if state == .background{
            
            
        }
        else{
            
            //foreground
            
        }
    }
    
    //앱이 켜져있는 상태에서 푸시받았을 때,(didrecieveRemotenotification 보다 최신버전, 7.0), 혹은 백그라운드에서 푸시를 클릭해서 들어왔ㄷ을때(앱이 꺼진 상태에서 제어 불가)
    @available(iOS 10.0, *)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler complitionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        
        //다른 기기에서 로그인이 되었다면 여기로 들어옵니다
        if let logout = userInfo[AnyHashable("logout")]{
         
            mainView.Logout()
        }
        complitionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    //앱을 닫고 백그라운드 상태가 되었을 때
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        //        let content = UNMutableNotificationContent()
        //        content.title = "Title: aaaaaa"
        //        content.subtitle="SubTitle: bbbbbbb"
        //        content.body="Body: ccccccc"
        //        content.badge = 1
        //
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
        //        let request = UNNotificationRequest(identifier: "timerdone", content: content, trigger: trigger)
        //
        //        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in })
        
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let urlConnectVC = UIApplication.shared.delegate as! AppDelegate
        
        urlConnectVC.tokenKey = InstanceID.instanceID().token()!;
        print(tokenKey)
        ConnectToFCM()
        
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
        
        ConnectToFCM()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "edepotMobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //Push받기 위한 핸드폰 고유 토큰키
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        print(deviceTokenString)
        tokenKey = InstanceID.instanceID().token()!;
        //shareExtension을 위해 꼭 필요한 코드!!
        let shareDefaults = UserDefaults(suiteName: "group.edepot")
        shareDefaults!.set(tokenKey, forKey:"tokenKey")
        
        Messaging.messaging().apnsToken = deviceToken

        
    }
    
  
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken
        fcmToken: String) {
        
        print("Firebase registration token: \(fcmToken)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage:
        MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}
