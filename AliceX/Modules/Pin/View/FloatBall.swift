//
//  FloatBall.swift
//  AliceX
//
//  Created by lmcmz on 1/9/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation
import UIKit

protocol FloatBallDelegate: class {
    func floatBallDidClick(floatBall: FloatBall)
    func floatBallBeginMove(floatBall: FloatBall)
    func floatBallEndMove(floatBall: FloatBall)
}

class FloatBall: UIView {
    @IBOutlet var containerView: UIVisualEffectView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: RPCircularProgress!

    let margin: CGFloat = 10
    weak var delegate: FloatBallDelegate?

    class func instanceFromNib() -> FloatBall {
        let view = UINib(nibName: nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FloatBall
        view.configure()
        return view
    }

    func configure() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        addGestureRecognizer(tap)
        imageView.image = UIImage.imageWithColor(color: WalletManager.currentNetwork.color)

        progressView.enableIndeterminate()

        containerView.layer.cornerRadius = frame.height / 2
        containerView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2

        layer.shadowColor = UIColor(hex: "#000000", alpha: 0.5).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        center = (touches.first?.location(in: UIApplication.shared.keyWindow))!
        guard let delegate = self.delegate else {
            return
        }
        delegate.floatBallBeginMove(floatBall: self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
        endTouch(point: (touches.first?.location(in: UIApplication.shared.keyWindow))!)
        guard let delegate = self.delegate else {
            return
        }
        delegate.floatBallEndMove(floatBall: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        endTouch(point: (touches.first?.location(in: UIApplication.shared.keyWindow))!)
        guard let delegate = self.delegate else {
            return
        }
        delegate.floatBallEndMove(floatBall: self)
    }

    func endTouch(point: CGPoint) {
        var frame = self.frame
        if point.x > Constant.SCREEN_WIDTH / 2 {
            frame.origin.x = Constant.SCREEN_WIDTH - frame.size.width - margin
        } else {
            frame.origin.x = margin
        }

        if frame.origin.y > Constant.SCREEN_HEIGHT - 64 {
            frame.origin.y = Constant.SCREEN_HEIGHT - 64
        } else if frame.origin.y < 20 {
            frame.origin.y = 20
        }

        UIView.animate(withDuration: 0.3) {
            self.frame = frame
        }
    }

    @objc func tapGesture(tap _: UIGestureRecognizer) {
        guard let delegate = self.delegate else {
            return
        }

        delegate.floatBallDidClick(floatBall: self)
    }
}
