//
//  VideoListViewController+TableViewDataSource.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/3/19.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - CoreData数据监控回调
extension VideoListViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
            
        case .update:
            //kvo 进行update，这里无需reload
            break
            
        case .insert:
            tableView.insertRows(at: [indexPath!], with: .fade)
            break
            
        case .move:
            if !indexPath!.elementsEqual(newIndexPath!) {
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
            break
        }
    }
}

// MARK: - TableViewDataSource和Delegate
extension VideoListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if playIndex(index: indexPath.row) {
            currentIndexPath = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoFetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoInfoTableViewCell", for: indexPath) as! VideoInfoTableViewCell
        cell.videoInfo = videoFetchedResultsController.fetchedObjects?[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}
