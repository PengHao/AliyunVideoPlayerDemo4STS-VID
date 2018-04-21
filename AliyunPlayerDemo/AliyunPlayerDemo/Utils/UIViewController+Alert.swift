//
//  UIViewController+Alert.swift
//  AliyunPlayerDemo
//
//  Created by peng hao on 2018/3/21.
//  Copyright © 2018年 peng hao. All rights reserved.
//

import Foundation
import UIKit

/// 自定义alertAction
struct Action {
    var title: String?
    var style: UIAlertActionStyle!
    var handler: ((Action) -> Swift.Void)?
}

// MARK: - UIViewController的扩展，用于在当前页面显示alert
extension UIViewController {
    func showAlert(title: String?, msg: String?, actions: Action...) {
        DispatchQueue.main.async { [weak self] in
            guard let ws = self else {
                return
            }
            guard actions.count > 0 else {
                return
            }
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            actions.forEach({ (action) in
                alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: { (newaction) in
                    action.handler?(action)
                    alert.dismiss(animated: true, completion: nil)
                }))
            })
            
            ws.present(alert, animated: true, completion: nil)
        }
    }
}
