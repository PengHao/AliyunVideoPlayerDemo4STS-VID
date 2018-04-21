//
//  PlayerViewController+AliyunVodDownLoadDelegate.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/10.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import AliyunVodPlayerSDK


enum VideoDownLoadError: Error {
    case VidError;              //下载的VID不是用户所选择的
    case QulaityError;          //下载的清晰度不用户所选择的
    case FormatError;           //下载的格式不用户所选择的
    
}


extension VideoListViewController : AliyunVodDownLoadDelegate {
    /*
       功能：开始下载后收到回调，更新最新的stsData。主要场景是开始多个下载时，等待下载的任务自动开始下载后，stsData有可能已经过期了，需通过此回调更新，该回调是在子线程调用
     参数：返回当前数据
     返回：使用代理方法，设置AliyunStsData来更新数据。
     */
    func onGetAliyunStsData(_ videoID: String!, format: String!, quality: AliyunVodPlayerVideoQuality) -> AliyunStsData! {
        let stsdata = AliyunStsData()
        //使用信号量来同步数据获取
        let semaphore = DispatchSemaphore(value: 0)
        AliYunCustomRequestManager.shared.getToken { (success, token) in
            if success {
                stsdata.accessKeyId = token?.accessKeyId
                stsdata.accessKeySecret = token?.accessKeySecret
                stsdata.securityToken = token?.token
            }
            semaphore.signal()
        }
        let rs = semaphore.wait(timeout: DispatchTime.now() + 30)
        let mediaInfo = AliyunDownloadMediaInfo()
        mediaInfo.quality = quality
        mediaInfo.format = format
        mediaInfo.vid = videoID
        if rs != .success {
            //获取sts data 超时
            showAlert(title: nil, msg: "get sts data time out", actions: Action(title: "OK", style: .cancel, handler: nil))
            updateProgress(mediaInfo: mediaInfo, status: .Failed)
        }
        if stsdata.accessKeyId == nil || stsdata.accessKeySecret == nil || stsdata.securityToken == nil {
            //获取sts data 返回错误
            showAlert(title: nil, msg: "get sts data return error", actions: Action(title: "OK", style: .cancel, handler: nil))
            updateProgress(mediaInfo: mediaInfo, status: .Failed)
        }
        
        return stsdata
    }
    
    func onGetAliyunMtsData(_ videoID: String!, format: String!, quality: String!) -> AliyunMtsData! {
        //因为使用STS，所以这里无需考虑MTS
        return nil;
    }
    
    
    static let qualityNames = [
        "流畅",
        "标清",
        "高清",
        "超清",
        "2K",
        "4K",
        "原画"
    ]
    
    /*
     功能：未完成回调，异常中断导致下载未完成，下次启动后会接收到此回调。
     回调数据：AliyunDownloadMediaInfo数组
     */
    func onUnFinished(_ mediaInfos: [AliyunDataSource]!) {
        //因为使用sts播放，所以在恢复的时候要更新一下source的stsData
        mediaInfos.forEach { (source) in
            AliYunCustomRequestManager.shared.getToken { (success, token) in
                let aliyunStsData = AliyunStsData()
                aliyunStsData.accessKeyId = token?.accessKeyId
                aliyunStsData.accessKeySecret = token?.accessKeySecret
                aliyunStsData.securityToken = token?.token
                source.stsData = aliyunStsData
            }
        }
    }
    
    /*
       功能：开始下载后收到回调，更新最新的playAuth。主要场景是开始多个下载时，等待下载的任务自动开始下载后，playAuth有可能已经过期了，需通过此回调更新
       */
    func onGetPlayAuth(_ vid: String!, format: String!, quality: AliyunVodPlayerVideoQuality) -> String! {
        //因为使用sts播放，所以playAuth这里返回nil
        return nil
    }
    
    
    /// 格式化文件大小
    ///
    /// - Parameter size: 文件大小,单位byte
    /// - Returns: 格式化后的字符串
    func sizeFormatString(size: Int64) -> String {
        let oneKB: Int64 = 1024
        let oneMB: Int64 = oneKB * oneKB
        let oneGB: Int64 = oneMB*oneKB
        if size > oneGB {
            let gb = Float(size)/Float(oneGB)
            return String(format: "%.2fGB", gb)
        } else if size > oneMB {
            let mb = Float(size)/Float(oneMB)
            return String(format: "%.2fMB", mb)
        } else if size > oneKB {
            let kb = Float(size)/Float(oneKB)
            return String(format: "%.2fKB", kb)
        } else {
            return String(format: "%lldB", size)
            
        }
        
    }
    
    /*
     功能：准备下载回调。
     回调数据：AliyunDownloadMediaInfo数组
     */
    func onPrepare(_ mediaInfos: [AliyunDownloadMediaInfo]!) {
        DispatchQueue.main.async { [weak self] in
            guard let ws = self else {
                return
            }
            let alert = UIAlertController(title: "选择下载版本", message: nil, preferredStyle: .actionSheet)
            mediaInfos.forEach({ (mediaInfo) in
                let title = VideoListViewController.qualityNames[Int(mediaInfo.quality.rawValue)]
                let size = ws.sizeFormatString(size: mediaInfo.size)
                let action = UIAlertAction(title: title + " : " + size, style: .`default`, handler: { _ in
                    AliYunCustomRequestManager.shared.getToken { (success, token) in
                        let source = AliyunDataSource()
                        source.vid = mediaInfo.vid
                        source.format = mediaInfo.format
                        source.requestMethod = .stsToken
                        source.format = mediaInfo.format
                        source.quality = mediaInfo.quality
                        let aliyunStsData = AliyunStsData()
                        aliyunStsData.accessKeyId = token?.accessKeyId
                        aliyunStsData.accessKeySecret = token?.accessKeySecret
                        aliyunStsData.securityToken = token?.token
                        source.stsData = aliyunStsData
                        self?.updateProgress(mediaInfo: mediaInfo, status: .Waiting)
                        AppDelegate.downloadingVideos[source.vid] = source
                        AliyunVodDownLoadManager.share().startDownloadMedia(source)
                    }
                })
                alert.addAction(action)
            })

            alert.addAction(UIAlertAction(title: "cancel", style: .`default`, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            ws.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
     功能：下载开始回调。
     回调数据：AliyunDownloadMediaInfo
     */
    func onStart(_ mediaInfo: AliyunDownloadMediaInfo!) {
        updateProgress(mediaInfo: mediaInfo, status: .Downloading)
    }
    
    func updateProgress(mediaInfo: AliyunDownloadMediaInfo!, status: DownloadStatus) {
        AppDelegate.writeQueueContext.perform {
            guard let videos = try? AppDelegate.writeQueueContext.fetch(VideoInfo.fetchRequest(vid: mediaInfo.vid)),
            videos.count > 0 else {
                //vid not found
                self.showAlert(title: nil, msg: "error: download video not found in CoreData", actions: Action(title: "OK", style: .cancel, handler: nil))
                return
            }
            
            let videoInfo =  videos[0]
            if status != .Waiting {
                guard videoInfo.cacheFormat == mediaInfo.format else {
                    //format error
                    self.showAlert(title: nil, msg: "error: download format is not user selected", actions: Action(title: "OK", style: .cancel, handler: nil))
                    return
                }
                guard videoInfo.cacheQuality == mediaInfo.quality.rawValue else {
                    //quality error
                    self.showAlert(title: nil, msg: "error: download quality is not user selected", actions: Action(title: "OK", style: .cancel, handler: nil))
                    return
                }
                if status != .Failed {
                    //因为sandbox的目录可能会随着每次启动发生改变，所以需要用相对路径
                    //https://stackoverflow.com/questions/26988024/document-or-cache-path-changes-on-every-launch-in-ios-8
                    let fileName = mediaInfo.downloadFilePath.split(separator: "/").last
                    videoInfo.cacheFilePath = fileName == nil ? mediaInfo.downloadFilePath : "/"+String(fileName!)
                }
            } else {
                videoInfo.cacheFormat = mediaInfo.format
                videoInfo.cacheQuality = Int16(mediaInfo.quality.rawValue)
            }
            
            if status != .Failed {
                videoInfo.cacheProgress = Int16(mediaInfo.downloadProgress)
            }
            videoInfo.cacheStatus = Int16(status.rawValue)
            try? AppDelegate.writeQueueContext.save()
        }
    }
    
    /*
       功能：下载进度回调。可通过mediaInfo.downloadProgress获取进度。
       回调数据：AliyunDownloadMediaInfo
       */
    func onProgress(_ mediaInfo: AliyunDownloadMediaInfo!) {
        updateProgress(mediaInfo: mediaInfo, status: .Downloading)
    }
    
    /*
       功能：调用stop结束下载时回调。
       回调数据：AliyunDownloadMediaInfo
       */
    func onStop(_ mediaInfo: AliyunDownloadMediaInfo!) {
        updateProgress(mediaInfo: mediaInfo, status: .Pause)
        AppDelegate.downloadingVideos[mediaInfo.vid] = nil
    }
    
    /*
       功能：下载完成回调。
       回调数据：AliyunDownloadMediaInfo
       */
    func onCompletion(_ mediaInfo: AliyunDownloadMediaInfo!) {
        updateProgress(mediaInfo: mediaInfo, status: .Complete)
        AppDelegate.downloadingVideos[mediaInfo.vid] = nil
    }
    
    /*
       功能：改变加密文件（调用changeEncryptFile时回调）。
       回调数据：重新加密之前视频文件进度
       */
    func onChangeEncryptFileProgress(_ progress: Int32) {
        print("onChangeEncryptFileProgress")
    }
    
    /*
       功能：改变加密文件后老的加密视频重新加密完成时回调。加密完成后注意删除老的加密文件。
       */
    func onChangeEncryptFileComplete() {
        print("onChangeEncryptFileComplete")
    }
    
    func onError(_ mediaInfo: AliyunDownloadMediaInfo!, code: Int32, msg: String!) {
        print("on download error, media Info = %@, code = %d, msg = %@", mediaInfo, code, msg)
        AppDelegate.downloadingVideos[mediaInfo.vid] = nil
    }
    
    
}
