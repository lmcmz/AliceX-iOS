//
//  WalletCconnectHelper.swift
//  AliceX
//
//  Created by lmcmz on 31/7/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import BigInt
import Foundation
import WalletConnect
import web3swift

// TODO: Complete it
class WalletCconnectHelper {
    static let shared = WalletCconnectHelper()

    var interactor: WCInteractor?
    let clientMeta = WCPeerMeta(name: "Alice",
                                url: "https://github.com/alicedapp/wallet-connect-swift")
    var defaultAddress: String = WalletManager.wallet!.address
    var defaultChainId: Int = WalletManager.currentNetwork.chainID

    func fromQRCode(scanString: String) {
        guard let session = WCSession.from(string: scanString) else {
            print("WC: invalid url")
            return
        }
        connect(session: session)
    }

    func connect(session: WCSession) {
        print("==> session", session)
        let interactor = WCInteractor(session: session, meta: clientMeta)

        configure(interactor: interactor)

        interactor.connect().done { [weak self] connected in
            guard let self = self else { return }
            self.connectionStatusUpdated(connected)
        }.cauterize()

        self.interactor = interactor
    }

    func configure(interactor: WCInteractor) {
        let accounts = [defaultAddress]
        let chainId = defaultChainId

        interactor.onSessionRequest = { [weak self] _, peer in
            guard let self = self else { return }
            let message = [peer.description, peer.url].joined(separator: "\n")

            self.showAlert(title: "Login",
                           content: message,
                           comfirmText: "Approve",
                           cancelText: "Reject",
                           comfirmBlock: {
                               self.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
                               HUDManager.shared.dismiss()
            }) {
                self.interactor?.rejectSession().cauterize()
            }
        }

        interactor.onDisconnect = { [weak self] _ in
            self?.connectionStatusUpdated(false)
        }

        interactor.onEthSign = { [weak self] id, params in

            guard let msgText = params[0].hexDecodeUTF8 else {
                HUDManager.shared.showError(text: "Message hex can't be decode")
                return
            }

            self?.showAlert(title: "Sign",
                            content: msgText,
                            comfirmText: "Sign",
                            cancelText: "Cancel",
                            comfirmBlock: {
                                self?.signEth(id: id, message: params[0])
                            }, cancelBlock: {
                                _ = self?.interactor?.rejectRequest(id: id, message: "User reject sign Message").cauterize()
                                HUDManager.shared.dismiss()
            })
        }

        interactor.onEthSendTransaction = { [weak self] id, transaction in
            let data = try! JSONEncoder().encode(transaction)
            let message = String(data: data, encoding: .utf8)
            self?.showAlert(title: "SendTransaction",
                            content: message!,
                            comfirmText: "Send",
                            cancelText: "Reject",
                            comfirmBlock: {
                                self?.sendEth(id: id, transactionJSON: message?.toJSON() as! [String: Any])
            }) {
                self?.interactor?.rejectRequest(id: id, message: "I don't have ethers").cauterize()
            }
        }

        interactor.onBnbSign = { [weak self] id, order in
            let message = order.encodedString
            self?.showAlert(title: "BNB Sign",
                            content: message,
                            comfirmText: "Sign",
                            cancelText: "Cancel",
                            comfirmBlock: {
                                self?.signBnbOrder(id: id, order: order)
            }) {
                self?.interactor?.rejectRequest(id: id, message: "User reject sign Message").cauterize()
                HUDManager.shared.dismiss()
            }
        }

        interactor.onDappletCheck = { [weak self] id, _ in
            self?.interactor?.approveRequest(id: id, result: "true").cauterize()
        }

        interactor.onDappletLoad = { [weak self] _, message in
            CallRNModule.dappletEvent(message: message.first!)
        }
    }

    func showAlert(title: String = "Alert",
                   content: String,
                   comfirmText: String = "Comfirm",
                   cancelText: String = "Cancel",
                   comfirmBlock: VoidBlock?,
                   cancelBlock: VoidBlock?) {
        let view = BaseAlertView.instanceFromNib(title: title,
                                                 content: content,
                                                 comfirmText: comfirmText,
                                                 cancelText: cancelText,
                                                 comfirmBlock: comfirmBlock!,
                                                 cancelBlock: cancelBlock!)

        HUDManager.shared.showAlertView(view: view,
                                        backgroundColor: .clear,
                                        haptic: .none,
                                        type: .centerFloat,
                                        widthIsFull: false)
    }

    func approve(accounts _: [String], chainId _: Int) {
//        interactor?.approveSession(accounts: accounts, chainId: chainId).done {
//            print("<== approveSession done")
//        }.cauterize()
    }

    func signEth(id: Int64, message: String) {
        TransactionManager.showSignMessageView(message: message) { signData in
            self.interactor?.approveRequest(id: id, result: signData).cauterize()
            HUDManager.shared.dismiss()
        }
    }

    func sendEth(id: Int64, transactionJSON: [String: Any]) {
        guard let tx = EthereumTransaction.fromJSON(transactionJSON) else { return }
        guard let options = TransactionOptions.fromJSON(transactionJSON) else { return }
        let value = options.value != nil ? options.value! : BigUInt(0)

        TransactionManager.showPaymentView(toAddress: tx.to.address,
                                           amount: value,
                                           data: tx.data,
                                           symbol: "ETH") { signData in
            self.interactor?.approveRequest(id: id, result: signData).cauterize()
            HUDManager.shared.dismiss()
        }
    }

    func signBnbOrder(id _: Int64, order _: WCBinanceOrder) {
//        let data = order.encoded
//        print("==> signbnbOrder", String(data: data, encoding: .utf8)!)
//        let signature = privateKey.sign(digest: Hash.sha256(data: data), curve: .secp256k1)!
//        let signed = WCBinanceOrderSignature(
//            signature: signature.dropLast().hexString,
//            publicKey: privateKey.getPublicKeySecp256k1(compressed: false).data.hexString
//        )
//        interactor?.approveBnbOrder(id: id, signed: signed).done({ confirm in
//            print("<== approveBnbOrder", confirm)
//        }).cauterize()
    }

    func connectionStatusUpdated(_: Bool) {
//        self.approveButton.isEnabled = connected
//        self.connectButton.setTitle(!connected ? "Connect" : "Disconnect", for: .normal)
    }

//    @IBAction func connectTapped() {
//        guard let string = uriField.text, let session = WCSession.from(string: string) else {
//            print("invalid uri: \(String(describing: uriField.text))")
//            return
//        }
//        if let i = interactor, i.connected {
//            i.killSession().done {  [weak self] in
//                self?.approveButton.isEnabled = false
//                self?.connectButton.setTitle("Connect", for: .normal)
//            }.cauterize()
//        } else {
//            connect(session: session)
//        }
//    }

//    @IBAction func approveTapped() {
//        guard let address = addressField.text,
//            let chainIdString = chainIdField.text else {
//                print("empty address or chainId")
//                return
//        }
//        guard let chainId = Int(chainIdString) else {
//            print("invalid chainId")
//            return
//        }
//        guard let address = EthereumAddress(address) else {
//            print("invalid eth or bnb address")
//            return
//        }
//        approve(accounts: [address], chainId: chainId)
//    }
}
