//
//  VideoInfoTableViewCell.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/10.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import UIKit
import SDWebImage


/// videoCell的用户事件回调
protocol VideoInfoTableViewCellDelegate {
    
    /// 点击下载按钮
    ///
    /// - Parameter videoInfo: 对应的video对象
    func onDownloadPressed(videoInfo: VideoInfo!)
}

/// 下载状态枚举
///
/// - Default: 默认状态
/// - Waiting: 等待下载
/// - Downloading: 下载中
/// - Pause: 暂停
/// - Complete: 下载完成
/// - Failed: 下载失败
enum DownloadStatus : Int {
    case Default = 0
    case Waiting = 1
    case Downloading = 2
    case Pause = 3
    case Complete = 4
    case Failed = 5
}

class VideoInfoTableViewCell: UITableViewCell {
    static let defaultCover = "http://pic22.photophoto.cn/20120330/0020033025728386_b.jpg"
    static let btnTitles: [String] = [
        "点击下载",             //0
        "排队中",              //1
        "下载中...[点击暂停]",   //2
        "点击恢复",  //3
        "已下载",    //4
        "下载失败"]  //5
    
    var videoInfo: VideoInfo! {
        didSet{
            if oldValue != nil {
                oldValue.removeObserver(self, forKeyPath: "cacheProgress")
                oldValue.removeObserver(self, forKeyPath: "cacheStatus")
            }
            
            titleLabel?.text = videoInfo.title
            durationLabel?.text = String(format:"%.2f", videoInfo.duration)
            //更新cover
            let cv = videoInfo.coverURL ?? VideoInfoTableViewCell.defaultCover
            let url = URL(string: cv)
            coverImageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "default"), options: .cacheMemoryOnly, progress: nil, completed: nil)
            
            updateCacheStatus()
            videoInfo.addObserver(self, forKeyPath: "cacheProgress", options: .new, context: nil)
            videoInfo.addObserver(self, forKeyPath: "cacheStatus", options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if "cacheProgress" == keyPath {
            progressView.progress = Float(videoInfo.cacheProgress)/100.0
        }
        else if "cacheStatus" == keyPath {
            progressView.isHidden = videoInfo.cacheStatus == 0
            let index : Int = Int(videoInfo.cacheStatus)
            let btnTitle = String(format:VideoInfoTableViewCell.btnTitles[index])
            downloadBtn.setTitle(btnTitle, for: .normal)
        }
    }
    
    var delegate: VideoInfoTableViewCellDelegate?
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var downloadBtn: UIButton!
    
    /// 更新缓存状态
    private func updateCacheStatus()  {
        let index : Int = Int(videoInfo.cacheStatus)
        let btnTitle = String(format:VideoInfoTableViewCell.btnTitles[index])
        downloadBtn.setTitle(btnTitle, for: .normal)
        progressView.isHidden = videoInfo.cacheStatus == 0
        progressView.progress = Float(videoInfo.cacheProgress)/100.0
    }

    /// 点击下载按钮
    @IBAction func onDownloadBtn(sender: UIButton!) {
        delegate?.onDownloadPressed(videoInfo: videoInfo)
    }
}
