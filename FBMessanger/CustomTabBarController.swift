//
//  CustomTabBarController.swift
//  FBMessanger
//
//  Created by SEUNG-WON KIM on 2018/03/23.
//  Copyright © 2018 SEUNG-WON KIM. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let layout = UICollectionViewFlowLayout()
    let friendsViewController = FriendsViewController(collectionViewLayout: layout)
    let recentMessageNaviController = UINavigationController(rootViewController: friendsViewController)
    recentMessageNaviController.tabBarItem.title = "Recent"
    recentMessageNaviController.tabBarItem.image = UIImage(named: "watch-24")
    
    
    viewControllers = [recentMessageNaviController, createDummyNaviControllerWithTitle(title: "Call", imageName: "phone-24"), createDummyNaviControllerWithTitle(title: "Group", imageName: "group-24"), createDummyNaviControllerWithTitle(title: "Setting", imageName: "settings-24")]
    
  }
  
  private func createDummyNaviControllerWithTitle(title: String, imageName: String) -> UINavigationController {
    let viewController = UIViewController()
    let naviController = UINavigationController(rootViewController: viewController)
    naviController.tabBarItem.title = title
    naviController.tabBarItem.image = UIImage(named: imageName)
    return naviController
  }
}
