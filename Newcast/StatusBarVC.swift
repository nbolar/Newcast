//
//  StatusBarVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/16/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage

class StatusBarVC: NSViewController {

    
    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    @IBOutlet weak var backgroundImageView: SDAnimatedImageView!
    
    private enum FadeType {
        case fadeIn, fadeOut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.insertVibrancyView(material: .light)
        let area = NSTrackingArea.init(rect: backgroundImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        backgroundImageView.addTrackingArea(area)
        visualEffectView.isHidden = true
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 4
        setBackgroundImage()
        NotificationCenter.default.addObserver(self, selector: #selector(setBackgroundImage), name: NSNotification.Name(rawValue: "setBackground"), object: nil)
        
    }
    
    private func fade(type: FadeType = .fadeOut) {
        
        let from = type == .fadeOut ? 1 : 0.2
        let to = 1 - from
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = from
        fadeAnim.toValue = to
        fadeAnim.duration = 0.3
        visualEffectView.layer?.add(fadeAnim, forKey: "opacity")
        
        visualEffectView.alphaValue = CGFloat(to)
        
    }
    
    @objc func setBackgroundImage(){
        if currentSelectedPodcastIndex != nil
        {
            backgroundImageView.sd_setImage(with: URL(string: podcastsImageURL[currentSelectedPodcastIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), completed: nil)
        }
        
    }
    
    override func mouseEntered(with event: NSEvent) {
        visualEffectView.isHidden = false
        fade(type: .fadeIn)
        
    }
    
    override func mouseExited(with event: NSEvent) {
        visualEffectView.isHidden = true
        fade(type: .fadeOut)
    }
    
}
