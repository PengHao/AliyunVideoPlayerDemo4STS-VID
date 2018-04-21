//
//  Snapshots+CoreDataProperties.swift
//  
//
//  Created by peng hao on 2018/1/12.
//
//

import Foundation
import CoreData


extension Snapshots {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Snapshots> {
        return NSFetchRequest<Snapshots>(entityName: "Snapshots")
    }

    @NSManaged public var url: String?
    @NSManaged public var videoInfo: VideoInfo?

}
