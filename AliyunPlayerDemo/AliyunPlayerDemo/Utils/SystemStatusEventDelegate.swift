//
//  SystemStatusNotificationDelegate.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/3/16.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import Reachability

@objc
/// 系统事件监听的代理
protocol SystemStatusEventDelegate {
    
    /// app被唤起
    @objc optional func becomeActive();
    
    /// app被退出到后台
    @objc optional func resignActive();
    
    /// 网络发生改变
    @objc optional func networkStateChange();
    
    /// 屏幕发生改变
    @objc optional func statusBarOrientationDidChange();
}

extension SystemStatusEventDelegate {
    
    /// 判断是否是iPhoneX
    var isIphoneX: Bool  {
        get {
            return UIScreen.main.bounds.size.height == 812 || UIScreen.main.bounds.size.width == 812
        }
    }
    
    /// 添加系统事件的监听
    func addSystemEventsObservers() {
        if (self.becomeActive != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        }
        
        if (self.resignActive != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(resignActive), name: .UIApplicationWillResignActive, object: nil)
        }
        
        if (self.networkStateChange != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(networkStateChange), name: .reachabilityChanged, object: nil)
            Reachability.forInternetConnection()?.startNotifier()
        }
        
        if (self.statusBarOrientationDidChange != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
        }
    }
    
    /// 移除监听
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

}
