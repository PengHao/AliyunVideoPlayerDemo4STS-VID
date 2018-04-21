//
//  PlayerViewController+AliyunVodPlayerDelegate.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/10.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import AliyunVodPlayerSDK

extension PlayerViewController : AliyunVodPlayerDelegate {
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        switch event {
        case .prepareDone:
            //播放准备完成时触发
            print("prepareDone")
            playStatus = PlayStatus.Prepared.rawValue
            tryplay()
            break;
        case .play:
            //暂停后恢复播放时触发
            print("play")
            playStatus = PlayStatus.Playing.rawValue
            stopLoadingAnimation()
            showPlayerControllerAnimation()
            startTimer()
            break;
        case .firstFrame:
            //播放视频首帧显示出来时触发
            print("firstFrame")
            break;
        case .pause:
            //视频暂停时触发
            print("pause")
            playStatus = PlayStatus.Paused.rawValue
            stopTimer()
            break;
        case .stop:
            //主动使用stop接口时触发
            print("stop")
            playStatus = PlayStatus.Stop.rawValue
            stopTimer()
            break;
        case .finish:
            //视频正常播放完成时触发
            playStatus = PlayStatus.Stop.rawValue
            print("finish")
            break;
        case .beginLoading:
            //视频开始载入时触发
            print("beginLoading")
            startLoadingAnimation()
            break;
        case .endLoading:
            //视频加载完成时触发
            print("endLoading")
            stopLoadingAnimation()
            break;
        case .seekDone:
            //视频Seek完成时触发
            stopLoadingAnimation()
            break;
        }
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, playBack errorModel: ALPlayerVideoErrorModel!) {
        //播放出错时触发，通过errorModel可以查看错误码、错误信息、视频ID、视频地址和requestId。
        showAlert(title: nil, msg: "on play error" + errorModel.errorMsg, actions: Action(title: "OK", style: .cancel, handler: nil))
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, willSwitchTo quality: AliyunVodPlayerVideoQuality) {
        //将要切换清晰度时触发
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, didSwitchTo quality: AliyunVodPlayerVideoQuality) {
        //清晰度切换完成后触发
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, failSwitchTo quality: AliyunVodPlayerVideoQuality) {
        //清晰度切换失败触发
    }
    
    func onCircleStart(with vodPlayer: AliyunVodPlayer!) {
        //开启循环播放功能，开始循环播放时接收此事件。
    }
}
