//
//  PlayerViewController+Network.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/3/16.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 系统事件的监听delegate实现
extension PlayerViewController : SystemStatusEventDelegate  {
    func networkStateChange(){
        guard player.isPlaying else {
            return
        }
        //网络切换，先暂停
        pause()
        //再尝试是否可以直接继续播放
        tryplay()
    }
    
    //恢复播放
    func becomeActive() {
        //因为退出到后台后无法监控屏幕旋转，所以进入前台需要主动判断一次
        statusBarOrientationDidChange()
        //进入前台后尝试恢复播放
        tryplay()
    }
    
    //退出到后台暂停播放
    func resignActive() {
        pause()
    }
    
    
    @objc func statusBarOrientationDidChange() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            //垂直
            bottenTop.constant = isIphoneX ? 50 : 20
            bottenLeading.constant = 20
            playerViewBottom.constant = 0
            playerViewTop.constant = isIphoneX ? 30 : 0
            playerViewLeading.constant = 0
            playerViewTrailing.constant = 0
            break
            
        case .unknown:
            //未知，不做处理
            break
        case .portraitUpsideDown:
            //颠倒
            bottenTop.constant = 20
            bottenLeading.constant = 20
            playerViewBottom.constant = isIphoneX ? 30 : 0
            playerViewTop.constant = 0
            playerViewLeading.constant = 0
            playerViewTrailing.constant = 0
            break
        case .landscapeLeft:
            // home键靠左
            bottenTop.constant = 20
            bottenLeading.constant = 20
            playerViewBottom.constant = 0
            playerViewTop.constant = 0
            playerViewLeading.constant = 0
            playerViewTrailing.constant = isIphoneX ? 30 : 0
            break
        case .landscapeRight:
            // home键靠右
            bottenTop.constant = 20
            bottenLeading.constant = isIphoneX ? 50 : 20
            playerViewBottom.constant = 0
            playerViewTop.constant = 0
            playerViewLeading.constant = isIphoneX ? 30 : 0
            playerViewTrailing.constant = 0
            break
        }
        player.playerView.setNeedsUpdateConstraints()
        player.playerView.layoutIfNeeded()
        backBtn.setNeedsUpdateConstraints()
        backBtn.layoutIfNeeded()
    }
}
