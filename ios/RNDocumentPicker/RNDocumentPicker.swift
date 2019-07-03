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

@objc(RNDocumentPicker)
public class RNDocumentPicker: NSObject, RCTBridgeModule, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    lazy var composeCallbacks = [RCTResponseSenderBlock]()
    
    public static func moduleName() -> String! {
        return "RNDocumentPicker"
    }
    
    @objc(show:callback:)
    public func show(options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
        let allowedUTIs = RCTConvert.nsArray(options["filetype"])
        
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController.init(documentTypes: allowedUTIs as! [String], in: .import)
        
        composeCallbacks.append(callback)
        
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        let rootViewController: UIViewController? = (UIApplication.shared.delegate as! ReactNativePopupNavigationProtocol).windowsManager?.getCurrentUIWindow()?.rootViewController
        
        
        rootViewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        let rootViewController: UIViewController? = (UIApplication.shared.delegate as! ReactNativePopupNavigationProtocol).windowsManager?.getCurrentUIWindow()?.rootViewController
        
        rootViewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode != .import {
            return
        }
        
        guard let callback = composeCallbacks.popLast() else { return }
        
        url.startAccessingSecurityScopedResource()
        
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSErrorPointer = nil
        coordinator.coordinate(readingItemAt: url, options: .resolvesSymbolicLink, error: error, byAccessor: { (newURL: URL) -> Void in
            var result = [String: Any]()
            
            result["uri"] = newURL.absoluteString
            result["fileName"] = newURL.lastPathComponent
            
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: newURL.path)
                result["fileSize"] = fileAttributes[.size]
            } catch {
                print("Couldn't get file attributes")
            }
            
            callback([NSNull(), result])
        })
        
        url.startAccessingSecurityScopedResource()
    }
}
