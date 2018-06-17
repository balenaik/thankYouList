//
//  AppDelegate.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import Firebase
import FirebaseAuth
import FacebookCore
//import FBSDKLoginKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var uid: String?
    var indexPath: IndexPath?
    var indexPathSection: Int?
    var indexPathRow: Int?
    var selectedDate: String?
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    override init() {
        super.init()
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // UIWindowを生成.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        guard let currentUser = Auth.auth().currentUser else {
            let loginVC = self.storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.window?.rootViewController = loginVC
            self.window?.makeKeyAndVisible()
            return true
        }

        moveUDDataToFirestoreIfNeeded()
        let mainTabBarController: MainTabBarController = MainTabBarController()
        let leftMenuVC = self.storyboard.instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        if let userName = currentUser.displayName {
            leftMenuVC.userNameString = userName
        }
        
        createRootViewController(mainViewController: mainTabBarController, subViewController: leftMenuVC)

        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return SDKApplicationDelegate.shared.application(application,
                                                             open: url,
                                                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                             annotation: [:])
    }
    
    func createRootViewController(mainViewController: UIViewController, subViewController: UIViewController) {
        let rootViewController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: subViewController)
        SlideMenuOptions.contentViewDrag = true
        SlideMenuOptions.shadowRadius = 4.0
        SlideMenuOptions.shadowOffset = CGSize(width: 4, height: 0)
        SlideMenuOptions.shadowOpacity = 0.2
        SlideMenuOptions.contentViewOpacity = 0.3
        self.window?.rootViewController = rootViewController
    }
    
    private func moveUDDataToFirestoreIfNeeded() {
        let userDefaults = UserDefaults.standard
        guard let storedThankYouDataUDList = userDefaults.object(forKey: "thankYouDataList") as? Data else { return }
        NSKeyedUnarchiver.setClass(ThankYouDataUD.self, forClassName: "ThankYouList.ThankYouData")
        guard let unarchiveThankYouDataUDList = NSKeyedUnarchiver.unarchiveObject(with: storedThankYouDataUDList) as? [ThankYouDataUD] else { return }
        if unarchiveThankYouDataUDList.count != 0 {
            moveUDDataToFirestore(thankYouDataUDList: unarchiveThankYouDataUDList)
        }
    }
    
    private func moveUDDataToFirestore(thankYouDataUDList: [ThankYouDataUD]) {
        guard let userMail = Auth.auth().currentUser?.email else {
            print("Not login? error")
            return
        }
        let userDefaults = UserDefaults.standard
        var copiedUDDataList: [ThankYouDataUD] = []
        if let oldThankYouDataList = userDefaults.object(forKey: "oldThankYouDataList") as? Data {
            if let unarchiveOldThankYouDataList = NSKeyedUnarchiver.unarchiveObject(with: oldThankYouDataList) as? [ThankYouDataUD] {
                copiedUDDataList = unarchiveOldThankYouDataList
            }
        }
        let allOldThankYouDataCount = copiedUDDataList.count + thankYouDataUDList.count
        var unCopiedUDDataList: [ThankYouDataUD] = []
        let db = Firestore.firestore()
        for thankYouDataUD in thankYouDataUDList {
            guard let thankYouValue = thankYouDataUD.thankYouValue, let thankYouDate = thankYouDataUD.thankYouDate else { return }
            let thankYouData = ThankYouData(id: "", value: thankYouValue, date: thankYouDate, timeStamp: Date())
            db.collection("users").document(userMail).collection("posts").addDocument(data: thankYouData.dictionary) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                    unCopiedUDDataList.append(thankYouDataUD)
                } else {
                    copiedUDDataList.append(thankYouDataUD)
                }
                if copiedUDDataList.count + unCopiedUDDataList.count == allOldThankYouDataCount {
                    let copiedData = NSKeyedArchiver.archivedData(withRootObject: copiedUDDataList)
                    let unCopiedData = NSKeyedArchiver.archivedData(withRootObject: unCopiedUDDataList)
                    userDefaults.set(copiedData, forKey: "oldThankYouDataList")
                    userDefaults.set(unCopiedData, forKey: "thankYouDataList")
                    userDefaults.synchronize()
                    print("copiedData:\(copiedUDDataList)")
                    print("unCopiedData:\(unCopiedUDDataList)")
                }
            }
        }
    }
}

