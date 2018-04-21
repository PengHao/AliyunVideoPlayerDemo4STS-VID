//
//  AppDelegate.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/8.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import UIKit
import CoreData
import AliyunVodPlayerSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static func getDocumentPath() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard paths.count > 0 else {
            return nil
        }
        
        return paths[0]
    }
    
    var backgroundDownloadTaskId : UIBackgroundTaskIdentifier!
    
    var window: UIWindow?
    
    static var downloadingVideos = [String : AliyunDataSource?]()
    
    static let mainQueueContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static let writeQueueContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    @objc func contextObjectsDidSave(notify: Notification) {
        AppDelegate.mainQueueContext.mergeChanges(fromContextDidSave: notify)
    }
    
    
    /// 初始化CoreData
    ///
    /// - Parameter path: coreData数据存储路径
    func initCoreData(path: String!) -> Bool {
        guard let modelURL = Bundle.main.url(forResource: "AliyunDemo", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                return false
        }
        let coodinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let coodinator1 = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let doc = path + "/aliyunDemo.sqlit"
        do {
            try coodinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URL(fileURLWithPath: doc), options: nil)
            try coodinator1.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URL(fileURLWithPath: doc), options: nil)
        } catch {
            print(error)
            return false
        }
        
        AppDelegate.writeQueueContext.persistentStoreCoordinator = coodinator
        AppDelegate.mainQueueContext.persistentStoreCoordinator = coodinator1
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.contextObjectsDidSave), name:.NSManagedObjectContextDidSave, object: AppDelegate.writeQueueContext)
        return true
    }
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        guard let path = AppDelegate.getDocumentPath(),
        initCoreData(path: path) else {
            return false
        }
        
        let encrptyFile = Bundle.main.path(forResource: "encryptedApp", ofType: "dat")
        AliyunVodDownLoadManager.share().setDownLoadPath(path)
        AliyunVodDownLoadManager.share().setEncrptyFile(encrptyFile)
        AliyunVodDownLoadManager.share().setMaxDownloadOperationCount(3)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        backgroundDownloadTaskId = application.beginBackgroundTask {
            application.endBackgroundTask(self.backgroundDownloadTaskId)
        }
        let backgroudDownloadSources = AppDelegate.downloadingVideos.filter { (vid, source) -> Bool in
            return source != nil
        }.flatMap { (vid, source) -> AliyunDataSource! in
            return source
        }
        AliyunVodDownLoadManager.share().startDownloadMedias(backgroudDownloadSources)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

