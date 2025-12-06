//
//  AppDelegate.swift
//  ThankYouList
//
//  Created by Aika Yamada on 4/11/17.
//  Copyright © 2017 Aika Yamada. All rights reserved.
//

import UIKit
import Combine
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import SharedResources

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let userRepository: UserRepository = DefaultUserRepository()
    private lazy var appCoordinator = AppCoordinator(
        window: window,
        userRepository: userRepository)
    private let analyticsManager: AnalyticsManager = DefaultAnalyticsManager()
    private var cancellable = Set<AnyCancellable>()

    override init() {
        super.init()
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        setupFirebase()
        setupNavigationBar()
        setupListView()
        reAuthenticateToProvider()
        observeAuthenticationChanges()

        appCoordinator.start()
        
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

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            if handleDeeplink(url: url) {
                return true
            }
            return ApplicationDelegate.shared.application(application,
                                                          open: url,
                                                          sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                          annotation: [:])
    }
}

private extension AppDelegate {
    func setupFirebase() {
        do {
            try Auth.auth().useUserAccessGroup(AppConst.teamIdAndAccessGroup)
        } catch let error as NSError {
            // Crashlytics.crashlytics().record(error: error)
            // TODO: Log error on Crashlytics
            print("Error setting user access group: %@", error)
        }
    }

    func setupNavigationBar() {
        // Setup NavigationBar in SwiftUI
        UINavigationBar.appearance().titleTextAttributes = [
            .font : UIFont.boldAvenir(ofSize: 17)
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font : UIFont.boldAvenir(ofSize: 32)
        ]
    }

    func setupListView() {
        // Setup SwiftUI ListView background color for iOS 15
        UITableView.appearance().backgroundColor = .clear
    }

    func reAuthenticateToProvider() {
        userRepository.reAuthenticateToProviderIfNeeded()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellable)
    }

    func observeAuthenticationChanges() {
        userRepository.observeAuthenticationChanges()
            .catch { _ in Just(nil) }
            .sink { [analyticsManager] userId in
                analyticsManager.setUserId(userId: userId)
            }
            .store(in: &cancellable)
    }

    func handleDeeplink(url: URL) -> Bool {
        do {
            try appCoordinator.handleDeeplink(url: url)
            return true
        } catch {
            return false
        }
    }
}

