//
//  ViewController+Network.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/10.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import CoreData

/// Aliyun的业务服务器请求
class AliYunCustomRequestManager {
    /// requestManager单例
    static let shared: AliYunCustomRequestManager = AliYunCustomRequestManager()
    
    /// 临时授权token
    private var currentToken: Token = Token()
    
    /// 更新token
    ///
    /// - Parameters:
    ///   - keyId: keyId
    ///   - keySecret: keySecret
    ///   - token: token
    func updateToken(keyId: String?, keySecret: String?, token: String?) {
        currentToken.accessKeyId = keyId
        currentToken.accessKeySecret = keySecret
        currentToken.token = token
    }
    
    typealias TokenHandle = ( _ success: Bool, _ token: Token?) -> Swift.Void
    
    typealias ResponseHandle = (Dictionary<String, Any>?, Error?) -> Swift.Void
    
    /// 服务器domain
    /// todo 请替换成自己的服务器地址
    static let DOMAIN = "DOMAIN"
    private init() {
        
    }
    
    /// 获取临时授权token
    ///
    /// - Parameter tokenHandle: 获取token后的回调
    func getToken(tokenHandle: @escaping TokenHandle) {
        if validateToken() {
            tokenHandle(true, currentToken)
            return
        }
        
        request(params: "/token/?uid=123", responseHandle:  { [weak self](result, error) in
            guard let ws = self,
                let data = result,
                let expiration = data["expiration"] as? NSNumber,
                let token = data["token"] as? String,
                let accessKey = data["accessKeyId"] as? String,
                let accessSecret = data["accessKeySecret"] as? String
                else {
                    tokenHandle(false, nil)
                    return
            }
            ws.currentToken.accessKeyId = accessKey
            ws.currentToken.accessKeySecret = accessSecret
            ws.currentToken.token = token
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            ws.currentToken.exprise = Date(timeIntervalSince1970: expiration.doubleValue/1000)
            tokenHandle(true, ws.currentToken)
        })
    }
    
    
    /// 校验token是否还有效
    ///
    /// - Returns: true: 有效, false: 无效
    func validateToken() -> Bool {
        guard let exp = currentToken.exprise else {
            return false
        }
        return Date().compare(exp) == .orderedAscending
    }
    
    /// json反序列化
    ///
    /// - Parameter data: 收到的Data
    /// - Returns: json 解析出来的字典
    func serializeJsonObject(data: Data?) -> Dictionary<String, Any>? {
        guard let d = data,
            let result = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, Any> else {
                return nil
        }
        return result
    }
    
    
    /// 发送请求
    ///
    /// - Parameters:
    ///   - params: 请求get入参
    ///   - responseHandle: response 回调block，已经解码后的json
    private func request(params: String, responseHandle: @escaping ResponseHandle) {
        guard let url = URL(string: AliYunCustomRequestManager.DOMAIN + params) else {
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error)  in
            let result = self?.serializeJsonObject(data: data)
            responseHandle(result, error)
            }.resume()
    }
    
    /// 请求videoList
    func requestVideoList() {
        request(params: "/videolist", responseHandle: {(result, error) in
            guard let resultData = result,
                let videoListData = resultData["VideoList"] as? Dictionary<String, Any>,
                let videoList = videoListData["Video"] as? Array<Any> else {
                    return
            }
            
            print("get Video list success!, videoList = %@", videoList)
            videoList.forEach({ (v) in
                guard let video = v as? Dictionary<String, AnyObject> else {
                    return
                }
                
                //修改返回数据的key，修改为和coredata的attribute name一致
                var videoInfoMap = Dictionary<String, AnyObject>()
                video.forEach({ (e) in
                    guard let f = e.key.first else {
                        return
                    }
                    let first = String(f);
                    videoInfoMap[first.lowercased() + e.key.dropFirst()] = e.value
                })
                
                let request = VideoInfo.fetchRequest(vid: videoInfoMap["videoId"] as! String)
                guard let videos = try? AppDelegate.writeQueueContext.fetch(request) else {
                    return
                }
                if videos.count > 0 {
                    videos[0].updateData(info: videoInfoMap as AnyObject)
                } else {
                    _ = VideoInfo.insert(info: videoInfoMap as AnyObject, context: AppDelegate.writeQueueContext)
                }
            })
            try? AppDelegate.writeQueueContext.save()
        })
    }
}

