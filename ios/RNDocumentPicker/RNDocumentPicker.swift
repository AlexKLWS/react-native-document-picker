//
//  RNDocumentPicker.swift
//  RNDocumentPicker
//
//  Created by Alex Korzh on 03/07/2019.
//  Copyright © 2019 Elialys. All rights reserved.
//

import Foundation
import UIKit
import React
import ReactNativePopupNavigation

@objc(RNNavigation)
public class RNDocumentPicker: NSObject, RCTBridgeModule, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    lazy var composeCallbacks = [RCTResponseSenderBlock]()
    
    public static func moduleName() -> String! {
        return "RNDocumentPicker"
    }
    
    @objc(show:callback:)
    public func show(options: NSDictionary, callback: RCTResponseSenderBlock) {
        let allowedUTIs = RCTConvert.NSArray(options["filetype"])
        
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController.init(documentTypes: allowedUTIs, in: .import)
        
        composeCallbacks.add(callback)
        
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        var rootViewController: UIViewController = (UIApplication.shared.delegate as ReactNativePopupNavigationProtocol).windowsManager.getCurrentUIWindow()
        while rootViewController.modalViewController != nil {
            rootViewController = rootViewController.modalViewController
        }
        
        rootViewController.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        var rootViewController: UIViewController = (UIApplication.shared.delegate as ReactNativePopupNavigationProtocol).windowsManager.getCurrentUIWindow()
        while rootViewController.modalViewController != nil {
            rootViewController = rootViewController.modalViewController
        }
        
        rootViewController.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode != .import {
            return
        }
        
        let callback = composeCallbacks.popLast()
        
        url.startAccessingSecurityScopedResource()
        
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSErrorPointer? = nil
        coordinator.coordinate(readingItemAt: url, options: .resolvesSymbolicLink, error: error, byAccessor: { (newURL: URL) -> Void in
            let result = [String: Any]()
            
            result["uri"] = newURL.absoluteString
            result["fileName"] = newURL.lastPathComponent
            
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: newURL.path)
                result["fileSize"] = fileAttributes[.size]
            }
            
            callback([NSNull(), result])
        })
        
        url.startAccessingSecurityScopedResource()
    }
}
