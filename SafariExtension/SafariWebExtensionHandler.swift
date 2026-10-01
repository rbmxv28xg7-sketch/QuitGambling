//
//  SafariWebExtensionHandler.swift
//  QuitGamblingExtension
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let message: Any?
        if #available(iOS 15.0, macOS 11.0, *) {
            message = request?.userInfo?[SFExtensionMessageKey]
        } else {
            message = request?.userInfo?["message"]
        }

        os_log(.default, "Quit Gambling Extension received message: %@", String(describing: message))

        let response = NSExtensionItem()
        if #available(iOS 15.0, macOS 11.0, *) {
            response.userInfo = [SFExtensionMessageKey: ["status": "ok", "version": "1.0"]]
        } else {
            response.userInfo = ["message": ["status": "ok", "version": "1.0"]]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }

}
