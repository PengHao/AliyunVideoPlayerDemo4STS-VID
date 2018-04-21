//
//  VideoInfo+CoreDataProperties.swift
//  
//
//  Created by peng hao on 2018/3/3.
//
//

import Foundation
import CoreData


extension VideoInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoInfo> {
        return NSFetchRequest<VideoInfo>(entityName: "VideoInfo")
    }

    @NSManaged public var cacheFilePath: String?
    @NSManaged public var cacheProgress: Int16
    @NSManaged public var cacheStatus: Int16
    @NSManaged public var coverURL: String?
    @NSManaged public var createTime: String?
    @NSManaged public var duration: Float
    @NSManaged public var modifyTime: String?
    @NSManaged public var size: Int32
    @NSManaged public var status: String?
    @NSManaged public var title: String?
    @NSManaged public var videoId: String?
    @NSManaged public var cacheFormat: String?
    @NSManaged public var cacheQuality: Int16
    @NSManaged public var snapshots: NSSet?

}

// MARK: Generated accessors for snapshots
extension VideoInfo {

    @objc(addSnapshotsObject:)
    @NSManaged public func addToSnapshots(_ value: Snapshots)

    @objc(removeSnapshotsObject:)
    @NSManaged public func removeFromSnapshots(_ value: Snapshots)

    @objc(addSnapshots:)
    @NSManaged public func addToSnapshots(_ values: NSSet)

    @objc(removeSnapshots:)
    @NSManaged public func removeFromSnapshots(_ values: NSSet)

}
