//
//  BrowserWrapperViewController.swift
//  AliceX
//
//  Created by lmcmz on 23/7/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation

// Wrapper Broswer For Switch Network
class BrowserWrapperViewController: BaseViewController {
    var vc: BrowserViewController!
    var urlString: String = "https://www.duckduckgo.com/"
    @objc var hk_iconImage: UIImage = UIImage.imageWithColor(color: UIColor(hex: "D5D5D5"))

    class func make(urlString: String) -> BrowserWrapperViewController {
        let vc = BrowserWrapperViewController()
        vc.urlString = urlString
        return vc
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        addBrowser()
        NotificationCenter.default.addObserver(self, selector: #selector(changeNetwork), name: .networkChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func addBrowser() {
        vc = BrowserViewController()
        vc.urlString = urlString
        vc.wrapper = self
        vc.willMove(toParent: self)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
    }

    @objc func changeNetwork() {
        urlString = vc.webview.url!.absoluteString
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        addBrowser()
    }
}
