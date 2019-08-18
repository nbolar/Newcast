//
//  PodcastDescriptionVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/7/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SwiftSoup

class PodcastDescriptionVC: NSViewController {
    
    @IBOutlet weak var backgroundImageView: NSImageView!
    @IBOutlet weak var descriptionLabelField: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
    }
    
    func setupUI(){
        view.insertVibrancyView(material: .light)
        backgroundImageView.alphaValue = 0.5
        do {
            let doc: Document = try SwiftSoup.parse(podcastDescription)
            descriptionLabelField.stringValue = (try doc.text())
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
}
