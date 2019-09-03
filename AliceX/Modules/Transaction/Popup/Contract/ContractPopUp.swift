//
//  ContractPopUp.swift
//  AliceX
//
//  Created by lmcmz on 26/6/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import BigInt
import MarqueeLabel
import PromiseKit
import UIKit

class ContractPopUp: UIViewController {
    @IBOutlet var payButton: UIControl!
    @IBOutlet var progressIndicator: RPCircularProgress!
    @IBOutlet var payButtonContainer: UIView!

//    @IBOutlet weak var sliderContainer: UIView!

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var functionLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var paramterLabel: MarqueeLabel!

    @IBOutlet var priceLabel: UILabel!

    @IBOutlet var gasPriceLabel: UILabel!
    @IBOutlet var gasTimeLabel: UILabel!
    @IBOutlet var gasBtn: UIControl!

    var gasLimit: BigUInt?
    var gasPrice: GasPrice = GasPrice.average

    var timer: Timer?
    var process: Int = 0
    var toggle: Bool = false

    var contractAddress: String!
    var functionName: String!
    var abi: String!
    var parameters: [Any]?
    var value: BigUInt!
    var extraData: Data!
    var successBlock: StringBlock?

    class func make(contractAddress: String,
                    functionName: String,
                    parameters: [Any],
                    extraData: Data,
                    value: BigUInt,
                    abi: String,
                    success: @escaping StringBlock) -> ContractPopUp {
        let vc = ContractPopUp()
        vc.contractAddress = contractAddress
        vc.functionName = functionName
        vc.successBlock = success
        vc.parameters = parameters
        vc.extraData = extraData
        vc.value = value
        vc.abi = abi
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.text = contractAddress
        valueLabel.text = value.readableValue
        functionLabel.text = functionName

//        let price = Float(value!)! * PriceHelper.shared.exchangeRate
//        priceLabel.text = "\(PriceHelper.shared.currentCurrency.symbol) \(price.rounded(toPlaces: 3))"

        payButtonContainer.layer.cornerRadius = 20
        payButtonContainer.layer.masksToBounds = true

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(hex: "333333").cgColor, UIColor(hex: "333333").cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = payButton.bounds
        payButtonContainer.layer.insertSublayer(gradient, at: 0)

        payButton.layer.masksToBounds = false
        payButton.layer.cornerRadius = 20
        payButton.layer.shadowColor = UIColor(hex: "2060CB").cgColor
        payButton.layer.shadowRadius = 10
        payButton.layer.shadowOffset = CGSize.zero
        payButton.layer.shadowOpacity = 0.3

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGesture.minimumPressDuration = 0
        payButton.addGestureRecognizer(longPressGesture)
        progressIndicator.updateProgress(0)

        paramterLabel.type = .continuous
        paramterLabel.speed = .duration(10)
        paramterLabel.fadeLength = 10.0
        paramterLabel.trailingBuffer = 30.0
        paramterLabel.text = parameters!.compactMap { "\($0)" }.joined(separator: ", ")

        paramterLabel.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pauseTap))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        paramterLabel.addGestureRecognizer(tapRecognizer)

        gasBtn.isUserInteractionEnabled = false

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gasChange(_:)),
                                               name: .gasSelectionCahnge, object: nil)

        firstly {
            GasPriceHelper.shared.getGasPrice()
        }.then {
            TransactionManager.shared.gasForContractMethod(to: self.contractAddress,
                                                           contractABI: self.abi,
                                                           methodName: self.functionName,
                                                           methodParams: self.parameters as! [AnyObject],
                                                           amount: self.value,
                                                           data: self.extraData)
        }.done { gasLimit in
            self.gasLimit = gasLimit
            self.gasPriceLabel.text = self.gasPrice.toCurrencyFullString(gasLimit: gasLimit)
            self.gasBtn.isUserInteractionEnabled = true
            self.gasTimeLabel.text = "Arrive in ~ \(self.gasPrice.time) mins"
        }.catch { error in
            print(error.localizedDescription)
            self.gasPriceLabel.text = "Failed to get gas"
            self.gasPriceLabel.textColor = UIColor(hex: "FF7E79")
        }
    }

    // MARK: - GAS Notification

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func gasButtonClick() {
        let vc = GasFeeViewController.make(gasLimit: gasLimit!)
        HUDManager.shared.showAlertVCNoBackground(viewController: vc)
    }

    @objc func gasChange(_ notification: Notification) {
        guard let text = notification.userInfo?["gasPrice"] as? String else { return }
        let gasPrice = GasPrice(rawValue: text)!
        self.gasPrice = gasPrice
        updateGas()
    }

    func updateGas() {
        gasTimeLabel.text = "Arrive in ~ \(gasPrice.time) mins"
        gasPriceLabel.text = gasPrice.toCurrencyFullString(gasLimit: gasLimit!)
    }

    @IBAction func payButtonClick() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.payButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.progressIndicator.updateProgress(0.2, animated: true, initialDelay: 0, duration: 0.2, completion: {
                self.progressIndicator.updateProgress(0)
            })
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.payButton.transform = CGAffineTransform.identity
            }
        }
    }

    @objc func pauseTap(_ recognizer: UIGestureRecognizer) {
        let continuousLabel2 = recognizer.view as! MarqueeLabel
        if recognizer.state == .ended {
            continuousLabel2.isPaused ? continuousLabel2.unpauseLabel() : continuousLabel2.pauseLabel()
        }
    }

    @objc func timeUpdate() {
        process += 1
        var precentage = (Double(process) / 100)

        progressIndicator.updateProgress(CGFloat(precentage))
        if precentage < 1 {
            return
        }

        if precentage >= 1 {
            precentage = 1
        }

        if toggle == false {
            #if DEBUG
                sendTx()
            #else
                biometricsVerify()
            #endif

            toggle = true
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                self.payButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }

            timer = Timer(timeInterval: 0.01, target: self, selector: #selector(timeUpdate),
                          userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .default)
            timer!.fire()

        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                self.payButton.transform = CGAffineTransform.identity
            }
            timer!.invalidate()
            progressIndicator.updateProgress(0)
            toggle = false
            process = 0

        default:
            break
        }
    }

    func biometricsVerify() {
        firstly {
            FaceIDHelper.shared.faceID()
        }.done { _ in
            self.sendTx()
        }
    }

    func sendTx() {
        do {
            let txHash = try TransactionManager.writeSmartContract(contractAddress: contractAddress!,
                                                                   functionName: functionName!,
                                                                   abi: abi!,
                                                                   parameters: parameters!,
                                                                   extraData: extraData,
                                                                   value: value!,
                                                                   gasPrice: gasPrice)
            successBlock!(txHash)
            dismiss(animated: true, completion: nil)
        } catch let error as WalletError {
            HUDManager.shared.showError(text: error.errorMessage)
        } catch {
            print(error)
            HUDManager.shared.showError()
        }
    }
}
