//
//  VideoInfo+Update.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/1/12.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import CoreData
import Dic2CoreDataAutoWriter
extension Snapshots : Dic2CoreDataAutoWriter.EntityProtocol {
}

extension VideoInfo : Dic2CoreDataAutoWriter.EntityProtocol {
    static func fetchRequest(vid : String) -> NSFetchRequest<VideoInfo> {
        let fetchRequest = NSFetchRequest<VideoInfo>(entityName: entityName()!)
        let request = NSFetchRequest<VideoInfo>(entityName: entityName()!)
        request.predicate = NSPredicate(format: "videoId == %@", vid)
        return fetchRequest
    }
}
