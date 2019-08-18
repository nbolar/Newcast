//
//  EpisodeInfoVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/6/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import WebKit
import SDWebImage

class EpisodeInfoVC: NSViewController {
    
    @IBOutlet weak var podcastTitleField: NSTextField!
    @IBOutlet weak var episodeInfoWebView: WKWebView!
    @IBOutlet weak var podcastImageView: SDAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: NSNotification.Name(rawValue: "showInfo"), object: nil)
        view.wantsLayer = true
        view.layer?.backgroundColor = .white
        view.layer?.cornerRadius = 8
        view.layer?.borderColor = NSColor.white.cgColor
        view.layer?.borderWidth = 0.0
        podcastImageView.wantsLayer = true
        podcastImageView.layer?.cornerRadius = 8
        podcastImageView.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        
        showInfo()
    }
    
    @objc func showInfo(){
        if episodeSelectedIndex != nil{
            podcastTitleField.stringValue = episodeTitles[episodeSelectedIndex]
            podcastImageView.sd_setImage(with: URL(string: podcastsImageURL[podcastSelecetedIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), completed: nil)
            episodeInfoWebView.setValue(false, forKey: "drawsBackground")
            episodeInfoWebView.loadHTMLString(episodeDescriptions[episodeSelectedIndex], baseURL: nil)
        }
        
        
    }
    
}
