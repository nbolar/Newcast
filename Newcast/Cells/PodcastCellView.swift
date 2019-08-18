//
//  PodcastCellView.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage

class PodcastCellView: NSCollectionViewItem {
    
    @IBOutlet weak var podcastImage: SDAnimatedImageView!
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
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.7
            view.layer?.borderWidth = selected ? 2.0 : 0.0
        }, completionHandler:{
        })   
    }
    
    func setSearchHighlight(selected: Bool){
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.7
            view.layer?.borderWidth = selected ? 4.0 : 0.0
        }, completionHandler:{
        })
    }
    func configurePodcastSearchCell(podcastCell: Parser)
    {
        podcastImage.sd_setImage(with: URL(string: podcastCell.imageURL), placeholderImage: NSImage(named: "placeholder"), options: .init(), completed: nil)
    }
    func configurePodcastAddedCell(podcastCell: String){
        podcastImage.sd_setImage(with: URL(string: podcastCell), placeholderImage: NSImage(named: "placeholder"), options: .init(), completed: nil)
    }
    
}
