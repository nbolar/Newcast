//
//  StatusBarVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/16/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage

var playPauseCheck: Int? = 0


class StatusBarVC: NSViewController {
    
    
    
    @IBOutlet weak var endTime: NSTextField!
    @IBOutlet weak var startTime: NSTextField!
    @IBOutlet weak var playerSlider: NSSlider!
    @IBOutlet weak var scrollingTextViewAuthor: ScrollingTextView!
    @IBOutlet weak var scrollingTextViewEpisode: ScrollingTextView!
    @IBOutlet weak var skipAheadButton: NSButton!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var skipBackButton: NSButton!
    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    @IBOutlet weak var backgroundImageView: SDAnimatedImageView!
    lazy var alertView: NSWindowController? = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "alertWindowController") as? NSWindowController
    
    private enum FadeType {
        case fadeIn, fadeOut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(setBackgroundImage), name: NSNotification.Name(rawValue: "setBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveSlider), name: NSNotification.Name(rawValue: "moveSlider"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPausePass), name: NSNotification.Name(rawValue: "playPausePassStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: NSNotification.Name(rawValue: "close"), object: nil)
        
    }
    
    func setupUI(){
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.backgroundColor = .black
        view.insertVibrancyView(material: .light)
        let area = NSTrackingArea.init(rect: backgroundImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        backgroundImageView.addTrackingArea(area)
        visualEffectView.isHidden = true
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 8
        playPauseButton.isHidden = true
        skipBackButton.isHidden = true
        skipAheadButton.isHidden = true
        scrollingTextViewEpisode.isHidden = true
        scrollingTextViewAuthor.isHidden = true
        scrollingTextViewEpisode.setup(string: "")
        scrollingTextViewAuthor.setup(string: "")
        startTime.stringValue = ""
        endTime.stringValue = ""
        setBackgroundImage()
        playPausePass()
    }
    
    override func viewDidAppear() {
        if playingIndex == nil{
            scrollingTextViewAuthor.setup(string: "                 No Podcast Playing")
            view.addSubview(scrollingTextViewAuthor)
            scrollingTextViewAuthor.speed = 0
        }
    }
    
    @objc func moveSlider(){
        if playerDuration != nil && playerSeconds != nil{
            playerSlider.maxValue = Double(playerDuration)
            playerSlider.floatValue = playerSeconds
        }
        if Double(playerDuration) >= 3600{
            endTime.stringValue = String(Int(Double(playerDuration) / 60) / 60) + ":" + String(format: "%02d", Int(Double(playerDuration) / 60) % 60) + ":" +  String(format: "%02d", Int(Double(playerDuration).truncatingRemainder(dividingBy: 60)))
        }else if !playerDuration.isNaN{
            endTime.stringValue = String(Int(Double(playerDuration) / 60) % 60) + ":" +  String(format: "%02d", Int(Double(playerDuration).truncatingRemainder(dividingBy: 60)))
        }
        
        if Double(playerSeconds) >= 3600{
            startTime.stringValue = String(Int(Double(playerSeconds) / 60) / 60) + ":" + String(format: "%02d", Int(Double(playerSeconds) / 60) % 60) + ":" +  String(format: "%02d", Int(Double(playerSeconds).truncatingRemainder(dividingBy: 60)))
        }else{
            startTime.stringValue = String(Int(Double(playerSeconds) / 60) % 60) + ":" +  String(format: "%02d", Int(Double(playerSeconds).truncatingRemainder(dividingBy: 60)))
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
        if playPauseCheck == 1{
            if playPauseButton.image?.name() == "play"{
                playPauseButton.image = NSImage(named: "pause")
            }else{
                playPauseButton.image = NSImage(named: "play")
            }
            playPauseCheck = 0
        }
        
    }
    
    @IBAction func playPauseButtonClicked(_ sender: Any) {
        
        if playingIndex == nil && episodeSelectedIndex == nil{
            if alertView?.window?.isVisible == true
            {
                alertView?.resignFirstResponder()
                alertView?.close()
            }else{
                
                displayPopUp()
            }
        }else{
            if playPauseButton.image?.name() == "play"{
                playCount = 0
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playButton"), object: nil)
            }else{
                pauseCount = 0
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pauseButton"), object: nil)
            }
        }
        
    }
    
    @objc func displayPopUp() {
        
        alertView?.window?.styleMask = .titled
        alertView?.window?.setFrameOrigin(NSPoint(x: xWidth, y: yHeight))
        alertView?.showWindow(self)
    }
    
    @objc func close(){
        if alertView?.window?.isVisible == true
        {
            alertView?.resignFirstResponder()
            alertView?.close()
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
            if playingIndex != nil{
                backgroundImageView.sd_setImage(with: URL(string: podcastsImageURL[currentSelectedPodcastIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), completed: nil)
                scrollingTextViewEpisode.setup(string: "\(episodeTitles[playingIndex])")
                scrollingTextViewAuthor.setup(string: "")
                scrollingTextViewEpisode.speed = 5
                view.addSubview(scrollingTextViewEpisode)
            }else if episodeSelectedIndex != nil{
                backgroundImageView.sd_setImage(with: URL(string: podcastsImageURL[currentSelectedPodcastIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), completed: nil)
                scrollingTextViewEpisode.setup(string: "\(episodeTitles[episodeSelectedIndex])")
                scrollingTextViewAuthor.setup(string: "")
                scrollingTextViewEpisode.speed = 5
                view.addSubview(scrollingTextViewEpisode)
            }
        }
    }
    @IBAction func newcastButtonClicked(_ sender: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Newcast.app"))
        self.dismiss(nil)
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
