//
//  MainViewController.swift
//  AliceX
//
//  Created by lmcmz on 15/8/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: Constant.SCREEN_WIDTH * CGFloat(MainTab.allCases.count),
                                        height: Constant.SCREEN_HEIGHT_NO_SAFE)
        contentView.frame = CGRect(x: 0, y: 0,
                                   width: Constant.SCREEN_WIDTH * CGFloat(MainTab.allCases.count),
                                   height: Constant.SCREEN_HEIGHT - Constant.SAFE_TOP)
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        
        MainTab.allCases.map { tab in
            let index = tab.rawValue
            let vc = tab.vc
            vc.willMove(toParent: self)
            vc.view.frame = CGRect(x: Constant.SCREEN_WIDTH * CGFloat(index),
                                   y: 0,
                                   width: Constant.SCREEN_WIDTH,
                                   height: Constant.SCREEN_HEIGHT - Constant.SAFE_TOP)
            contentView.addSubview(vc.view)
            addChild(vc)
            vc.didMove(toParent: self)
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /// Disbale vertical scroll
//        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
//            scrollView.contentOffset.y = 0
//        }

    }
}
