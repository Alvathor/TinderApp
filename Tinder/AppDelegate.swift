//
//  AppDelegate.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFirebase()
        setupInitialWindow()
        return true
    }
    
    fileprivate func setupInitialWindow() {
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = HomeController()
//        window?.rootViewController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    fileprivate func setupFirebase() {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }

}

