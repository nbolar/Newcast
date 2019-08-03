//
//  PodcastCellView.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

class PodcastCellView: NSCollectionViewItem {

    @IBOutlet weak var podcastImage: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        self.view.layer?.cornerRadius = 8
        self.view.layer?.borderColor = NSColor.white.cgColor
        self.view.layer?.borderWidth = 0.0
        podcastImage.wantsLayer = true
        podcastImage.layer?.cornerRadius = 8
        
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 2.0 : 0.0
    }

    
}
