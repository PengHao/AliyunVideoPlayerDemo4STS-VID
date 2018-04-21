//
//  VideoListViewController+TableViewDelegate.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/3/19.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import Reachability
import AliyunPlayerSDK
import AliyunVodPlayerSDK

// MARK: - VidewCell的用户事件回调
extension VideoListViewController : VideoInfoTableViewCellDelegate{
    
    
    /// 获取当前网络提示
    ///
    /// - Returns: 网络提示文案，如果返回nil则不提示
    func networkTips() -> String? {
        guard let reachability = Reachability.forInternetConnection() else {
            return "网络状态异常,请检查异常"
        }
        switch reachability.currentReachabilityStatus() {
        case .NotReachable:
            //断网，提示
            return "网络断开链接，请检查您的设备网络链接情况"
        case .ReachableViaWiFi:
            //切换到wifi，不管
            return nil
        case .ReachableViaWWAN:
            //切换到移动网络，提示
            return "网络切换到移动网络，继续下载将消耗手机的流量，请问需要继续下载吗？"
        }
    }
    
    /// 获取最新的token，准备下载video
    ///
    /// - Parameter videoInfo: 需要下载的video对象
    func prepareDownloadVideo(videoInfo: VideoInfo!)  {
        AliYunCustomRequestManager.shared.getToken { [weak self](success, token) in
            guard success else {
                self?.showAlert(title: nil, msg: "getToken failed!", actions: Action(title: "OK", style: .cancel, handler: nil))
                return
            }
            let source = AliyunDataSource()
            source.vid = videoInfo.videoId
            source.requestMethod = .stsToken
            source.quality = .videoLD
            let aliyunStsData = AliyunStsData()
            aliyunStsData.accessKeyId = token?.accessKeyId
            aliyunStsData.accessKeySecret = token?.accessKeySecret
            aliyunStsData.securityToken = token?.token
            source.stsData = aliyunStsData
            self?.aliyunVodDownLoadManager?.prepareDownloadMedia(source)
        }
    }
    
    func onDownloadPressed(videoInfo: VideoInfo!) {
        guard let message = networkTips() else {
            prepareDownloadVideo(videoInfo: videoInfo)
            return
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "继续", style: .`default`, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            self.prepareDownloadVideo(videoInfo: videoInfo)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .`default`, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    /// 点击播放对应index的视频
    ///
    /// - Parameter index: 视频列表的index
    /// - Returns: true:成功 false:失败
    func playIndex(index: Int) -> Bool {
        guard let playList = videoFetchedResultsController.fetchedObjects else {
            return false
        }
        
        guard playList.count > 0 else {
            return false
        }
        
        guard let playerVC = PlayerViewController.create(playList: playList, playIndex: index) else {
            return false
        }
        present(playerVC, animated: true, completion: nil)
        return true
    }
}
