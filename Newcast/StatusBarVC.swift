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

    
   
    @IBOutlet weak var playerSlider: NSSlider!
    @IBOutlet weak var scrollingTextViewAuthor: ScrollingTextView!
    @IBOutlet weak var scrollingTextViewEpisode: ScrollingTextView!
    @IBOutlet weak var skipAheadButton: NSButton!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var skipBackButton: NSButton!
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
        playPauseButton.isHidden = true
        skipBackButton.isHidden = true
        skipAheadButton.isHidden = true
        scrollingTextViewEpisode.isHidden = true
        scrollingTextViewAuthor.isHidden = true
        scrollingTextViewEpisode.setup(string: "")
        scrollingTextViewAuthor.setup(string: "")
        setBackgroundImage()
        NotificationCenter.default.addObserver(self, selector: #selector(setBackgroundImage), name: NSNotification.Name(rawValue: "setBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveSlider), name: NSNotification.Name(rawValue: "moveSlider"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPausePass), name: NSNotification.Name(rawValue: "playPausePass"), object: nil)
        
    }
    
    @objc func moveSlider(){
        if playerDuration != nil && playerSeconds != nil{
            playerSlider.maxValue = Double(playerDuration)
            playerSlider.floatValue = playerSeconds
        }
        if playerSlider.doubleValue == Double(playerDuration){
            pauseCount = 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pauseButton"), object: nil)
        }
        
    }
    @IBAction func skip30AheadClicked(_ sender: Any) {
        playerSlider.doubleValue += 30
        if playerSlider.doubleValue <= playerSlider.maxValue{
            musicSliderPositionChanged(Any?.self)
        }else{
            playerSlider.doubleValue = playerSlider.maxValue
            musicSliderPositionChanged(Any?.self)
        }
    }
    
    @IBAction func skip30BehindClicked(_ sender: Any) {
        playerSlider.doubleValue -= 30
        if playerSlider.doubleValue >= 0{
            musicSliderPositionChanged(Any?.self)
        }else{
            playerSlider.doubleValue = 0
            musicSliderPositionChanged(Any?.self)
        }
    }
    
    @objc func playPausePass(){
        if playPauseButton.image?.name() == "play"{
            playPauseButton.image = NSImage(named: "pause")
        }else{
            playPauseButton.image = NSImage(named: "play")
        }
    }
    
    @IBAction func playPauseButtonClicked(_ sender: Any) {
        if playPauseButton.image?.name() == "play"{
            playCount = 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playButton"), object: nil)
        }else{
            pauseCount = 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pauseButton"), object: nil)
        }
    }
    
    @IBAction func musicSliderPositionChanged(_ sender: Any) {
        test = playerSlider.doubleValue
        sliderStop = 0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sliderChanged"), object: nil)
    }
    
    private func fade(type: FadeType = .fadeOut) {
        
        let from = type == .fadeOut ? 1 : 0.05
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
            scrollingTextViewEpisode.setup(string: "\(episodeTitles[playingIndex ?? episodeSelectedIndex])")
//            scrollingTextViewAuthor.setup(string: "\(podcastsTitle[currentSelectedPodcastIndex])")
            scrollingTextViewEpisode.speed = 4
            scrollingTextViewAuthor.speed = 4
            view.addSubview(scrollingTextViewEpisode)
            view.addSubview(scrollingTextViewAuthor)
        }
        
    }
    
    override func mouseEntered(with event: NSEvent) {
        visualEffectView.isHidden = false
        playPauseButton.isHidden = false
        skipBackButton.isHidden = false
        skipAheadButton.isHidden = false
        scrollingTextViewEpisode.isHidden = false
        scrollingTextViewAuthor.isHidden = false
        fade(type: .fadeIn)
        
    }
    
    override func mouseExited(with event: NSEvent) {
        visualEffectView.isHidden = true
        playPauseButton.isHidden = true
        skipBackButton.isHidden = true
        skipAheadButton.isHidden = true
        scrollingTextViewEpisode.isHidden = true
        scrollingTextViewAuthor.isHidden = true
        fade(type: .fadeOut)
    }

}
