//
//  EpisodeInfoVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/6/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import WebKit

class EpisodeInfoVC: NSViewController {

    @IBOutlet weak var episodeInfoWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: NSNotification.Name(rawValue: "showInfo"), object: nil)
        view.wantsLayer = true
        view.layer?.backgroundColor = .white
        view.layer?.cornerRadius = 8
        view.layer?.borderColor = NSColor.white.cgColor
        view.layer?.borderWidth = 1.0
        showInfo()
    }
    
    @objc func showInfo(){
        episodeInfoWebView.setValue(false, forKey: "drawsBackground")
        
        episodeInfoWebView.loadHTMLString(episodeDescriptions[episodeSelectedIndex], baseURL: nil)
        
    }
    
}
