//
//  ViewController.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/8.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import UIKit
import CoreData
import Dic2CoreDataAutoWriter
import AliyunVodPlayerSDK
import Reachability

class VideoListViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var tableViewTop : NSLayoutConstraint!
    @IBOutlet var tableViewBottom : NSLayoutConstraint!
    @IBOutlet var tableViewLeading : NSLayoutConstraint!
    @IBOutlet var tableViewTrailing : NSLayoutConstraint!
    
    lazy var aliyunVodDownLoadManager: AliyunVodDownLoadManager? = {
        let manager = AliyunVodDownLoadManager.share()
        manager?.downloadDelegate = self
        return manager
    }()
    
    lazy var videoFetchedResultsController : NSFetchedResultsController<VideoInfo> = {
        let fetchRequest = NSFetchRequest<VideoInfo>(entityName: VideoInfo.entityName()!)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "modifyTime", ascending: true)
        ]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.mainQueueContext, sectionNameKeyPath: "status", cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    /// 当前选择的cell Index
    var currentIndexPath: IndexPath?;
    
    //因为fetchedResultsController只会监控已经查询出来的数据，所以如果发现context有新增的数据，需要重新查询一遍
    @objc func onInsertVideoInfo(notification: Notification) {
        guard let insertObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<AnyHashable>,
            insertObjects.count > 0 else {
                return
        }
        try? self.videoFetchedResultsController.performFetch()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSystemEventsObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(onInsertVideoInfo), name: .NSManagedObjectContextObjectsDidChange, object: AppDelegate.mainQueueContext)
        try? videoFetchedResultsController.performFetch()
        AliYunCustomRequestManager.shared.requestVideoList()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 10))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarOrientationDidChange()
    }
}


