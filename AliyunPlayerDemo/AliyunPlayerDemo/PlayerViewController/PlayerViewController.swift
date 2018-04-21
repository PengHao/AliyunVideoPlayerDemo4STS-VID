//
//  PlayerViewController.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/10.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import UIKit
import Reachability
import AliyunVodPlayerSDK




enum PlayStatus : Int {
    case Stop = 1          //停止
    case Preparing = 2     //准备中
    case Prepared = 3      //准备完成
    case Paused = 4        //暂停
    case Playing = 5       //播放
}

/// 播放器VC
class PlayerViewController: UIViewController {
    /// 播放器对象
    let player : AliyunVodPlayer = AliyunVodPlayer()
    /// 当前播放列表
    var playList: [VideoInfo] = [VideoInfo]()
    /// 当前播放的index
    var playIndex: Int = 0
    /// timer
    var timer :Timer!
    /// 播放器承载view
    
    var playerViewTop : NSLayoutConstraint!
    var playerViewBottom : NSLayoutConstraint!
    var playerViewLeading : NSLayoutConstraint!
    var playerViewTrailing : NSLayoutConstraint!
    
    
    @IBOutlet weak var bottenLeading: NSLayoutConstraint!
    
    @IBOutlet weak var bottenTop: NSLayoutConstraint!
    @IBOutlet var playerContentView: UIView!
    /// 播放器控制view
    @IBOutlet var playerControllerView: UIView!
    /// 播放器进度条
    @IBOutlet var progressView: UIProgressView!
    /// 缓存进度条
    @IBOutlet var cacheProgressView: UIProgressView!
    /// loading
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    @IBOutlet var backBtn: UIButton!
    
    @IBOutlet var playBtn: UIButton!
    
    var playStatus: Int = PlayStatus.Stop.rawValue {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let ws = self else {
                    return
                }
                
                ws.playBtn.isSelected = ws.playStatus == PlayStatus.Playing.rawValue
            }
        }
    }
    
    
    /// 点击播放按钮
    ///
    /// - Parameter sender: 按钮sender
    @IBAction func onPlayBtn(sender: UIButton?) {
        if playStatus == PlayStatus.Playing.rawValue {
            pause()
        } else {
            tryplay()
        }
    }
    
    /// 点击返回按钮
    ///
    /// - Parameter sender: 按钮sender
    @IBAction func onBackBtn(sender: UIButton?) {
        pause();
        dismiss(animated: true, completion: nil)
    }
    
    /// 点击上一集
    @IBAction func onPrevBtn() {
        playIndex = playIndex < 1 ? 0 : playIndex - 1
        player.stop()
        preparePlay()
    }
    
    /// 点击下一集
    @IBAction func onNextBtn() {
        playIndex = playIndex > playList.count - 1 ? playList.count - 1 : playIndex + 1
        preparePlay()
    }
    
    /// 显示控制栏的菜单
    func showPlayerControllerAnimation()  {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.playerControllerView.alpha = 0.0
            self?.backBtn.alpha = 0.0
            }, completion: { [weak self] (finished) in
                self?.playerControllerView.isHidden = true
                self?.backBtn.isHidden = true
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerControllerView.isHidden = false
        backBtn.isHidden = false
        backBtn.alpha = 0.7
        playerControllerView.alpha = 0.7
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: { [weak self] in
            guard let ws = self else {
                return
            }
            ws.showPlayerControllerAnimation()
        })
    }
    
    /// 创建PlayerViewController
    ///
    /// - Parameter playList: 播放列表
    /// - Parameter playIndex: 播放第几个
    /// - Returns: vc对象
    static func create(playList: [VideoInfo]!, playIndex: Int) -> PlayerViewController? {
        guard playIndex >= 0 && playIndex < playList.count else {
            return nil
        }
        let rs = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        rs.playList = playList
        rs.playIndex = playIndex
        return rs
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.displayMode = .fit
        player.delegate = self
        //player.circlePlay = true //设置了循环播放，接收不到finish消息。
        player.playerView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        playerContentView.addSubview(player.playerView)
        player.playerView.translatesAutoresizingMaskIntoConstraints = false
        
        playerViewBottom = NSLayoutConstraint(item: player.playerView, attribute: .bottom, relatedBy: .equal, toItem: playerContentView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        playerViewTop = NSLayoutConstraint(item: player.playerView, attribute: .top, relatedBy: .equal, toItem: playerContentView, attribute: .top, multiplier: 1.0, constant: isIphoneX ? 30 : 0)
        
        playerViewLeading = NSLayoutConstraint(item: player.playerView, attribute: .leading, relatedBy: .equal, toItem: playerContentView, attribute: .leading, multiplier: 1.0, constant: 0)
        
        playerViewTrailing = NSLayoutConstraint(item: player.playerView, attribute: .trailing, relatedBy: .equal, toItem: playerContentView, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        playerContentView.addConstraints([playerViewBottom, playerViewTop, playerViewLeading, playerViewTrailing])
        
        addSystemEventsObservers()
        activityView.isHidden = true
        progressView.progress = 0
        cacheProgressView.progress = 0
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarOrientationDidChange()
    }
    
    deinit {
        removeObservers()
    }
    
    
    @objc func updateProcess() {
        cacheProgressView.progress = Float(player.loadedTime/player.duration)
        progressView.progress = Float(player.currentTime/player.duration)
    }
    
    /// timer开始更新进度
    func startTimer()  {
        stopTimer()
        
        timer = Timer(timeInterval: 1.0/30.0, target: self, selector: #selector(PlayerViewController.updateProcess), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        timer.fire()
    }
    
    /// 终止timer
    func stopTimer() {
        if timer == nil {
            return
        }
        timer.invalidate()
    }
    
    /// 显示loading
    func startLoadingAnimation() {
        activityView.isHidden = false
        activityView.startAnimating()
    }
    
    /// 隐藏loading
    func stopLoadingAnimation() {
        activityView.stopAnimating()
        activityView.isHidden = true
    }
    
}

// MARK: - 播放相关逻辑
extension PlayerViewController {
    
    
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
            return "网络切换到移动网络，继续播放将消耗手机的流量，请问需要继续播放吗？"
        }
    }
    
    
    func pause() {
        player.pause()
        playBtn.isSelected = false
    }
    
    func stop() {
        player.stop()
        playBtn.isSelected = false
    }
    
    func play()  {
        if playStatus == PlayStatus.Paused.rawValue {
            player.resume()
        } else if playStatus == PlayStatus.Prepared.rawValue {
            player.start()
        }
        playBtn.isSelected = true
    }
    
    func tryplay() {
        guard playStatus > PlayStatus.Preparing.rawValue else {
            showAlert(title: "Error", msg: "video not prepared, please wait a moment!", actions: Action(title: "cancel", style: .cancel, handler: nil))
            preparePlay()
            return
        }
        
        guard let message = networkTips() else {
            play()
            return
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "继续", style: .`default`, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            self.play()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .`default`, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /// 离线播放
    ///
    /// - Parameter path: 本地缓存视频地址
    func prepareOffline(videoInfo: VideoInfo) -> Bool {
        
        guard let path = videoInfo.cacheFilePath else {
            return false
        }
        
        guard  let doc = AppDelegate.getDocumentPath() else {
            showAlert(title: "Error", msg: "have not set cache file path!", actions: Action(title: "cancel", style: .cancel, handler: nil))
            return false
        }
        
        guard  FileManager.default.fileExists(atPath: doc + path) else {
            showAlert(title: "Error", msg: "file not exists!", actions: Action(title: "cancel", style: .cancel, handler: nil))
            return false
        }
        
        guard videoInfo.cacheStatus == DownloadStatus.Complete.rawValue else {
            showAlert(title: "Error", msg: "video have not download complete", actions: Action(title: "cancel", style: .cancel, handler: nil))
            return false
        }
        playStatus = PlayStatus.Preparing.rawValue
        player.prepare(with: URL(fileURLWithPath: AppDelegate.getDocumentPath()!+path))
        return true
    }
    
    /// 在线播放
    private func prepareOnline(videoInfo: VideoInfo) {
        AliYunCustomRequestManager.shared.getToken { [weak self](success, token) in
            if !success {
                self?.showAlert(title: "Error", msg: "get token failed", actions: Action(title: "cancel", style: .cancel, handler: nil))
                return
            }
            guard let ws = self,
                let tk = token,
                let accessKeyId = tk.accessKeyId,
                let accessKeySecret = tk.accessKeySecret,
                let securityToken = tk.token,
                let vid = videoInfo.videoId
                else {
                    self?.showAlert(title: "Error", msg: "get token nil", actions: Action(title: "cancel", style: .cancel, handler: nil))
                    return
            }
            ws.playStatus = PlayStatus.Preparing.rawValue
            ws.player.prepare(withVid: vid, accessKeyId: accessKeyId, accessKeySecret: accessKeySecret, securityToken: securityToken)
        }
    }
    
    /// 播放
    private func preparePlay() {
        guard playIndex >= 0 && playIndex < playList.count else {
            return
        }
        if player.isPlaying {
            player.stop()
        }
        //先尝试离线播放，失败才在线播放
        if prepareOffline(videoInfo: playList[playIndex]) {
            return
        }
        print("play offline failed")
        prepareOnline(videoInfo: playList[playIndex])
        
    }
}
