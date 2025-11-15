//
//  ShareViewController.swift
//  ShareExtension
//
//  Share extension to accept text from other apps
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Extract text from the shared item
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            completeRequest()
            return
        }
        
        // Check for plain text
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
                if let text = item as? String {
                    self?.saveAndOpenMainApp(with: text)
                } else {
                    self?.completeRequest()
                }
            }
        }
        // Check for RTF text
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.rtf.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.rtf.identifier, options: nil) { [weak self] (item, error) in
                var extractedText = ""
                
                if let data = item as? Data {
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.rtf
                    ]
                    if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                        extractedText = attributedString.string
                    }
                }
                
                if !extractedText.isEmpty {
                    self?.saveAndOpenMainApp(with: extractedText)
                } else {
                    self?.completeRequest()
                }
            }
        } else {
            completeRequest()
        }
    }
    
    private func saveAndOpenMainApp(with text: String) {
        // Save text to shared UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: "group.com.workoutsummary.app") {
            sharedDefaults.set(text, forKey: "sharedText")
            sharedDefaults.synchronize()
        }
        
        // Open the main app
        if let url = URL(string: "workoutsummary://share") {
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open(url, options: [:], completionHandler: nil)
                    break
                }
                responder = responder?.next
            }
        }
        
        // Complete the extension request
        completeRequest()
    }
    
    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
