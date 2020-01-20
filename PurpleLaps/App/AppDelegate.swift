//
//  AppDelegate.swift
//  PurpleLaps
//
//  Created by Mikhail Kalugin on 4/25/18.
//  Copyright © 2018 Mikhail Kalugin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  override init() {
    super.init()
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
  
    let nav = UINavigationController()
    window?.rootViewController = nav
    
    let mainVC = MainViewController()
    nav.pushViewController(mainVC, animated: false)
    
    return true
  }
}

