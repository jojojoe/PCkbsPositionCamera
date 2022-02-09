//
//  SubscribeProtocal.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//


import Foundation
import SwiftyStoreKit
import AppsFlyerLib

let cacheIapInfoMonthKey = "cacheIapInfo_month"
let cacheIapInfoWeekKey = "cacheIapInfo_month"
let cacheIapInfoYearKey = "cacheIapInfo_month"

let AF_event_Week = "subscribe_month"
let AF_event_Month = "subscribe_month"
let AF_event_Year3Free = "subscribe_month"


protocol SubscriptionBaseProtocol {
    
    
}

extension SubscriptionBaseProtocol {
    
    // MARK: -
    func getSubscriptionData(com: @escaping ([SubscriptionModel])->()) {
        //
        let productIds = SubscriptionType.allType.map{$0.iapStr}
        PurchaseManager.share.fetchProductsInfo(productIds: productIds) { (items) in
            guard items.count > 0 else { return }
            //
            var new = [SubscriptionModel]()
            for product in items {
                //
                let model = SubscriptionModel(iapID: product.productIdentifier, price: product.price.doubleValue, currencySymbol: product.priceLocale.currencySymbol ?? "$", localizedPrice: product.localizedPrice ?? String(format: "%@%.2f", (product.priceLocale.currencySymbol ?? "$"),product.price.doubleValue))
                new.append(model)
                // cache
                
                let infoDict: [String: Any] = ["iapID": model.iapID, "price": model.price, "currencySymbol": model.currencySymbol, "localizedPrice": model.localizedPrice]
                if model.iapType == .month {
                    UserDefaults.standard.set(infoDict, forKey: cacheIapInfoMonthKey)
                } else if model.iapType == .week {
                    UserDefaults.standard.set(infoDict, forKey: cacheIapInfoWeekKey)
                } else if model.iapType == .year {
                    UserDefaults.standard.set(infoDict, forKey: cacheIapInfoYearKey)
                }
            }
            //
            com(new)
        }
    }

    func buySubscription(type: SubscriptionType,source: String,page: String,comp: @escaping (PurchaseDetails?)->()) {
        //
        
        //
        PurchaseManager.share.purchaseFailBlock = { error in
            
        }
        //
        PurchaseManager.share.startPurchaseProduct(iapIdStr: type.iapStr) { (purchaseDetails) in
            //
            comp(purchaseDetails)
            // 测试已更新, 这里填写新的AppsFlyer的标识码
            var AppsFlyerStr = ""
            switch type {
            case .month:
                AppsFlyerStr = AF_event_Month
            case .year:
                AppsFlyerStr = AF_event_Year3Free
            case .week:
                AppsFlyerStr = AF_event_Week
            }
            
            //
            if let purchaseDetails = purchaseDetails {
                debugPrint("purchaseDetails = \(purchaseDetails)")
                
                let price = purchaseDetails.product.price.doubleValue
                let currencyCode = purchaseDetails.product.priceLocale.currencyCode ?? "USD"
                //
                
                AppsFlyerLib.shared().logEvent(AppsFlyerStr,
                                               withValues: [
                                                AFEventParamRevenue: (price * 0.4),
                                                AFEventParamCurrency: currencyCode,
                                                AFEventParamContentId: type.iapStr,
                                               ]);
                
            }
        }
    }
    
    func restoreFunc(comp: @escaping ()->()) {
        PurchaseManager.share.restore(comp: comp)
    }
}
