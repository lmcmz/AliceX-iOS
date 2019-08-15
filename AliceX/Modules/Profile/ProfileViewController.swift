//
//  ProfileViewController.swift
//  AliceX
//
//  Created by lmcmz on 15/8/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import UIKit
import SPStorkController

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func settingClick() {
        let modal = SettingViewController()
        let navi = BaseNavigationController(rootViewController: modal)
        let transitionDelegate = SPStorkTransitioningDelegate()
        navi.transitioningDelegate = transitionDelegate
        navi.modalPresentationStyle = .custom
        transitionDelegate.showIndicator = false
        transitionDelegate.indicatorColor = UIColor.white
        transitionDelegate.hideIndicatorWhenScroll = true
        self.present(navi, animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
