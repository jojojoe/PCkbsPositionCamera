//
//  PCkPurchaseM.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//


import Foundation
import SwiftyStoreKit
import StoreKit
import ZKProgressHUD

let sharedSecret_debug = "53947d67a981482cb327a0971c768478"
let sharedSecret_release = "53947d67a981482cb327a0971c768478"

extension Notification.Name {
    
    static let PurchaseSubscrtionStateChange = Notification.Name("PSPurchaseSubscrtionStateChange")
    public static let buy = Notification.Name("PSkSubscribeBuy")
}


enum SubscriptionType {
    case week
    case month
    case year
    
    static var allType: [SubscriptionType] {
        return [.week]
    }
    
    //测试,已更新
    var iapStr: String {
        switch self {
        case .week:
            return "com.picpli.pailide.month"
        case .month:
            return "com.picpli.pailide.month"
        case .year:
            return "com.picpli.pailide.month"
        }
    }
}

struct SubscriptionModel {
    
    let iapID: String
    let price: Double
    let currencySymbol: String
    let localizedPrice: String
    
    // MARK: -
    
    var iapType: SubscriptionType {
        //
        switch self.iapID {
        case SubscriptionType.week.iapStr:
            return .week
        case SubscriptionType.month.iapStr:
            return .month
        case SubscriptionType.year.iapStr:
            return .year
        default:
            return .month
        }
    }
    
}


extension Double {
    
    func toEveryMonthPriceStr(_ count: Int) -> String {
        //
        var temp = ((self/count.double)*100).int.double / 100
        if count == 1 {
            temp = self
        }
        return String(format: "%.2f", temp)
    }
    
}


class PurchaseManager {
    
    public static var share = PurchaseManager()
    
    var purchaseFailBlock: (_ error: String)->() = {_ in}
    
    func setUp() {
        //
        SwiftyStoreKit.completeTransactions { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
        //
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment,product in
            //itms-services://?action=purchaseIntent&bundleId=com.gamekeyboard.themestest1&productIdentifier=com.gamekeyboard.themes.month
            //            GKMyVipViewController().show(source: "AppStore")
            return false
        }
        //
        if PurchaseManager.share.inSubscription {
            self.verifyReceipt {}
        }
    }
    
    private var receiptInfo: ReceiptInfo? {
        set{
            if let jsonData = newValue?.jsonData() {
                UserDefaults.standard.set(jsonData, forKey: "PurchaseManager_ReceiptInfo_key")
                UserDefaults.standard.synchronize()
            }
        }
        get{
            if let data = UserDefaults.standard.data(forKey: "PurchaseManager_ReceiptInfo_key"),
               let obj = try? data.jsonObject() as? ReceiptInfo {
                return obj
            }
            return nil
        }
    }
    
    func getReceiptInfo() -> ReceiptInfo? {
        return self.receiptInfo
    }
    
    // 请求产品的数据
    func fetchProductsInfo(productIds: [String],comp: @escaping (_ productModels: Set<SKProduct>)->()) {
        //
        let ids = Set(productIds)
        //
        SwiftyStoreKit.retrieveProductsInfo(ids) { result in
            let products = result.retrievedProducts
            comp(products)
        }
    }
    
    
    /// 发起购买
    func startPurchaseProduct(iapIdStr: String,comp: @escaping (_ purchase: PurchaseDetails?)->()) {
        
        ZKProgressHUD.show()
        //
        purchaseProduct(iapIdStr: iapIdStr) { purchaseDetails in
            // ReceiptInfo
            
            self.verifyReceipt(iapIdStr: iapIdStr) {
                //
                
                ZKProgressHUD.dismiss()
                //
                DispatchQueue.main.async {
                    
                    comp(purchaseDetails)
                }
            }
        }
    }
    
    /// 购买方法
    private func purchaseProduct(iapIdStr: String,comp: @escaping (_ purchase: PurchaseDetails)->()) {
        //
        SwiftyStoreKit.purchaseProduct(iapIdStr) { (result) in
            switch result {
            case .success(let purchase):
                //
                comp(purchase)
            case .error(let error):
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showError(error.localizedDescription)
                
                self.purchaseFailBlock(error.localizedDescription)
             
            }
        }
    }
    
    /// 购买验证凭据
    private func verifyReceipt(iapIdStr: String = "",comp: @escaping ()->()) {
        //
        if self.test {
            comp()
            return
        }
        
        // 测试已更新, 这里填写新的sharedSecret
        #if DEBUG
        let receiptValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret_debug)//
        #else
        let receiptValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret_release)
        #endif
        //
        SwiftyStoreKit.verifyReceipt(using: receiptValidator) { result in
            switch result {
            case .success(let receipt):
                //
                self.receiptInfo = receipt
                //
                if !iapIdStr.isEmpty {
                    //
                    let productId = iapIdStr
                    //
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productId, inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(expiryDate: _, items: _):
                        comp()
                    case .expired(expiryDate: _, items: _):
                        comp()
                    case .notPurchased:
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showError("")
                    }
                     
                } else {
                    comp()
                }
            case .error(let error):
        
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showError(error.localizedDescription)
                
                self.purchaseFailBlock(error.localizedDescription)
            }
        }
    }
    
    func restore(comp: @escaping ()->()) {
        //测试
        //        HUD.show()
        //        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
        //            self.test = true
        //            HUD.hide()
        //            NotificationCenter.default.post(name: .PurchaseSubscrtionStateChange, object: nil)
        //            comp()
        //        }
        //        return;
        
         
        ZKProgressHUD.show()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoredPurchases.count > 0 {
                self.verifyReceipt {
                    ZKProgressHUD.dismiss()
                    NotificationCenter.default.post(name: .PurchaseSubscrtionStateChange, object: nil)
                    comp()
                }
            } else {
                //
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showError("Restore Failed".localized())
            }
        }
    }
    
    //
    var test = false
    
    // 判断订阅有效
    var inSubscription: Bool {
        //
        if UIApplication.shared.inferredEnvironment == .debug && test {
            return true
        }
        
        guard let receiptInfo = receiptInfo else { return false }
        
        let subscriptionIDList = Set(SubscriptionType.allType.map{$0.iapStr})
        let subscriptionInfo = SwiftyStoreKit.verifySubscriptions(productIds: subscriptionIDList, inReceipt: receiptInfo)
        switch subscriptionInfo {
        case let .purchased(expiryDate, items):
            //
            debugPrint("expiryDate - \(expiryDate)")
            expiryDate.string(withFormat: "yyyy-MM-dd")
            debugPrint("items - \(items)")
            let compare = Date().compare(expiryDate)
            let inPurchase = compare != .orderedDescending
            return inPurchase
        case .expired, .notPurchased:
            return false
        }
    }
    
}







