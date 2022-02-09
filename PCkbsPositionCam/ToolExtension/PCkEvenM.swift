//
//  PCkEvenM.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//

import Foundation
import AppsFlyerLib
import UIKit

class AFlyerLibManage: NSObject, AppsFlyerLibDelegate {
    
    var appsFlyerDevKey = ""
    var appleAppID = ""
    
    init(appsFlyerDevKey: String, appleAppID: String) {
        super.init()
        
        self.appsFlyerDevKey = appsFlyerDevKey
        self.appleAppID = appleAppID
        
        AppsFlyerLib.shared().appsFlyerDevKey = self.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = self.appleAppID
        AppsFlyerLib.shared().delegate = self
        /* Set isDebug to true to see AppsFlyer debug logs */
        
        if UIApplication.shared.inferredEnvironment == .debug {
            AppsFlyerLib.shared().isDebug = true
        }
        
        if let afSource = UserDefaults.standard.dictionary(forKey: "AppsFlyerLib") {
            debugPrint("afSource = \(afSource)")
        }
        
        AppsFlyerLib.shared().start()
    }
    
    func getAppsFlyerUID() -> String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    static func flyerLibContinue(userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
    
    static func flyerLibHandleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]? = [:]) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }
    
    static func flyerLibHandlePushNotification(userInfo: [AnyHashable : Any]) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        let source: [String : Any] = installData as? [String : Any] ?? [:]
        debugPrint("onConversionDataSuccess data:")
        for (key, value) in installData {
            debugPrint(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    debugPrint("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                debugPrint("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                debugPrint("First Launch")
            } else {
                debugPrint("Not First Launch")
            }
        }
        
        UserDefaults.standard.setValue(source, forKey: "AppsFlyerLib")
        UserDefaults.standard.synchronize()
        
    }
    
    static func getConversionDataSuccess() -> [String: Any] {
        let value = UserDefaults.standard.dictionary(forKey: "AppsFlyerLib")
        return value ?? [:]
    }
    
    func onConversionDataFail(_ error: Error) {
        
        debugPrint("onConversionDataFail -- " + error.localizedDescription)

    }
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        
        debugPrint(attributionData)
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        debugPrint("onAppAttributionFailure -- " + error.localizedDescription)
    }
        
    static func event_PurchaseSuccessAll(symbolType: String, needMoney: Float, iapId: String) {
        
        AppsFlyerLib.shared().logEvent("pi_purchase",
                                       withValues: [
                                        AFEventParamContent  : symbolType,
                                        AFEventParamRevenue  : needMoney * 0.4,
                                        AFEventParamContentId: iapId])
    }
    
    static func event_LaunchApp() {
        AppsFlyerLib.shared().logEvent("pi_launch", withValues: nil)
    }
    
    static func event_button_1stclick() {
        AppsFlyerLib.shared().logEvent("", withValues: nil)
    }
    
    static func event_button_2stclick() {
        AppsFlyerLib.shared().logEvent("", withValues: nil)
    }
    
}
