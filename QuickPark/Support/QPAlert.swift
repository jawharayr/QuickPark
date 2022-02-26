//
//  SAlert.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 26/02/2022.
//

import UIKit

public struct QPAlert {
    let viewController:UIViewController
    
    init (_ vc:UIViewController) {
        self.viewController = vc
    }
    
    @discardableResult
    func showError(message: String?) -> UIAlertController {
        showAlert(title: nil,  message: message ?? "Unexpected error!")
    }
    
    @discardableResult
    func showAlert(title: String? = nil, message: String?, onOK: (() -> Void)? = nil) -> UIAlertController {
        showAlert(title: title, message: message, buttons: ["OK"]) { _, _ in
            onOK?()
        }
    }
    
    @discardableResult
    func showAlert(title: String? = nil, message: String?, buttons: [String], handler: ((UIAlertController, Int) -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if buttons.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .cancel) { [unowned alert] _ in
                handler?(alert, 0)
            })
        } else {
            for (idx, button) in buttons.enumerated() {
                alert.addAction(UIAlertAction(title: button, style: .default) { [unowned alert] _ in
                    handler?(alert, idx)
                })
            }
        }
        viewController.present(alert, animated: true, completion: nil)
        return alert
    }
}

