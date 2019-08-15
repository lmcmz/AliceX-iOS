//
//  MainTab.swift
//  AliceX
//
//  Created by lmcmz on 15/8/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation

enum MainTab: Int, CaseIterable {
    case mini
    case asset
//    case transaction
    case profile

    var vc: UIViewController {
        switch self {
        case .mini:
            return AssetViewController()
        case .asset:
            return AssetViewController()
//        case .transaction:
//            return UIViewController()
        case .profile:
            return ProfileViewController()
//            return ProfileViewController()
        }
    }

    var icon: UIImage {
        switch self {
        case .mini:
            return UIImage(named: "back")!
        case .asset:
            return UIImage(named: "back")!
//        case .transaction:
//            return UIImage(named: "back")!
        case .profile:
            return UIImage(named: "back")!
        }
    }
}
