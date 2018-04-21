//
//  VideoListViewController+Network.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/3/18.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import Reachability
import AliyunVodPlayerSDK

// MARK: - 系统事件监听回调
extension VideoListViewController : SystemStatusEventDelegate {
    
    func showNetworkAlert(message: String!, canResume: Bool, downloadingMedias: [AliyunDownloadMediaInfo])  {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if canResume {
            alert.addAction(UIAlertAction(title: "继续", style: .`default`, handler: { _ in
                let downloadingSources = downloadingMedias.flatMap({ (mediaInfo) -> AliyunDataSource? in
                    let source = AliyunDataSource()
                    source.format = mediaInfo.format
                    source.vid = mediaInfo.vid
                    source.quality = mediaInfo.quality
                    source.videoDefinition = mediaInfo.videoDefinition
                    return source
                })
                AliyunVodDownLoadManager.share().startDownloadMedias(downloadingSources)
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "取消", style: .`default`, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func networkStateChange(){
        guard let reachability = Reachability.forInternetConnection() else {
            return
        }
        var msg: String? = nil
        var canResume = false
        switch reachability.currentReachabilityStatus() {
        case .NotReachable:
            //断网，提示
            msg = "网络断开链接，请检查您的设备网络链接情况"
            break
        case .ReachableViaWiFi:
            //切换到wifi，不管
            return
        case .ReachableViaWWAN:
            //切换到移动网络，提示
            msg = "网络切换到移动网络，继续播放将消耗手机的流量，请问需要继续下载吗？"
            canResume = true
            break
        }
        
        guard let message = msg else {
            return
        }
        
        guard let downloadingMedias = AliyunVodDownLoadManager.share().downloadingdMedias() else {
            //没有正在下载的内容
            return
        }
        //先暂停
        AliyunVodDownLoadManager.share().stopDownloadMedias(downloadingMedias)
        showNetworkAlert(message: message, canResume: canResume, downloadingMedias: downloadingMedias)
    }
    
    
    func isNetworkAvaliable() -> Bool {
        guard let reachability = Reachability.forInternetConnection() else {
            return false
        }
        switch reachability.currentReachabilityStatus() {
        case .NotReachable:
            //断网，提示
            
            return false
        case .ReachableViaWiFi:
            //切换到wifi，不管
            return true
        case .ReachableViaWWAN:
            //切换到移动网络，提示
            return true
        }
    }
    
    
    @objc func statusBarOrientationDidChange() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            //垂直
            tableViewBottom.constant = 0
            tableViewTop.constant = 0
            tableViewLeading.constant = 0
            tableViewTrailing.constant = 0
            break
            
        case .unknown:
            //未知，不做处理
            break
        case .portraitUpsideDown:
            //颠倒
            tableViewBottom.constant = isIphoneX ? 30 : 0
            tableViewTop.constant = 0
            tableViewLeading.constant = 0
            tableViewTrailing.constant = 0
            break
        case .landscapeLeft:
            // home键靠左
            tableViewBottom.constant = 0
            tableViewTop.constant = 0
            tableViewLeading.constant = 0
            tableViewTrailing.constant = isIphoneX ? 30 : 0
            break
        case .landscapeRight:
            // home键靠右
            tableViewBottom.constant = 0
            tableViewTop.constant = 0
            tableViewLeading.constant = isIphoneX ? 30 : 0
            tableViewTrailing.constant = 0
            break
        }
        tableView.setNeedsUpdateConstraints()
        tableView.layoutIfNeeded()
    }
    
}
