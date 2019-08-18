//
//  EpisodeCellView.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/4/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage
import SwiftSoup
import AVFoundation
import CircularProgressMac

/// Episode selected under a certain podcast
var episodeSelectedIndex: Int!

/// Index of the playing epsiode
var playingIndex: Int!
var player: AVPlayer! = nil

/// Array containing the times at which each podcast episode has been paused at
var pausedTimes = [CMTime?](repeating: nil, count: episodes.count)

/// Dictionary containing the podcast index and the corresponding pasued times
var pausedTimesDictionary = [Int: [CMTime?]]()

/// Player current time in seconds
var playerSeconds: Float!

/// Duration of an episode
var playerDuration: Float!

/// Index of the presently selected podcast which may/may not be the same as the podcastSelectedIndex variable
var currentSelectedPodcastIndex: Int!

/// Variable used to prevent the collection view from repeatedly showing the play button
var playCount: Int? = nil

/// Variable used to prevent the collection view from repeatedly showing the pause button
var pauseCount: Int? = nil

var test: Float64? = nil
var sliderStop: Int? = nil
class EpisodeCellView: NSCollectionViewItem {
    
    
    
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var infoButton: NSButton!
    @IBOutlet weak var episodeDescriptionField: NSTextField!
    @IBOutlet weak var episodePubDateField: NSTextField!
    @IBOutlet weak var episodeTitleField: NSTextField!
    let networkIndicator = NSProgressIndicator()
    var previousPlayer: AVPlayer? = nil
    var pausedTime: CMTime? = nil
    var duration: String!
    let popoverView = NSPopover()
    let circularProgress = CircularProgress(size: 30)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        self.view.layer?.cornerRadius = 8
        self.view.layer?.borderColor = NSColor.white.cgColor
        self.view.layer?.borderWidth = 0.0
        infoButton.alphaValue = 0
        infoButton.isEnabled = false
        playButton.alphaValue = 0
        playButton.isEnabled = false
        pauseButton.alphaValue = 0
        pauseButton.isEnabled = false
        episodePubDateField.textColor = .lightGray
        
        let labelXPostion:CGFloat = 325
        let labelYPostion:CGFloat = view.bounds.midY + 13
        let labelWidth:CGFloat = 30
        let labelHeight:CGFloat = 30
        circularProgress.isIndeterminate = true
        circularProgress.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        circularProgress.color = NSColor.init(red: 0.39, green: 0.82, blue: 1.0, alpha: 0.9)
        NotificationCenter.default.addObserver(self, selector: #selector(playTestFunction), name: NSNotification.Name(rawValue: "playButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTestFunction), name: NSNotification.Name(rawValue: "pauseButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(seekToPosition), name: NSNotification.Name(rawValue: "sliderChanged"), object: nil)
        
        
    }    
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 2.0 : 0.0
    }
    
    
    @objc func playTestFunction(){
        if playCount == episodeSelectedIndex{
            playPauseButtonClicked(Any?.self)
            playCount = nil
        }
        if playCount != nil{
            playCount! += 1
        }
        
    }
    
    @objc func pauseTestFunction(){
        if pauseCount == episodeSelectedIndex{
            playPauseButtonClicked(Any?.self)
            pauseCount = nil
        }
        if pauseCount != nil{
            pauseCount! += 1
        }
        
    }
    /// Configures the Episode Cells
    func configureEpisodeCell(episodeCell: Episodes){
        
        episodeTitleField.stringValue = episodeCell.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d, yyyy"
        if episodeCell.episodeDuration.contains(":")
        {
            episodePubDateField.stringValue = "\(dateFormatter.string(from: episodeCell.pubDate)) • \(episodeCell.episodeDuration)"
        }else{
            if episodeCell.episodeDuration.count != 0 {
                if Double(episodeCell.episodeDuration)! >= 3600{
                    duration = String(Int(Double(episodeCell.episodeDuration)! / 60) / 60) + ":" + String(format: "%02d", Int(Double(episodeCell.episodeDuration)! / 60) % 60) + ":" +  String(format: "%02d", Int(Double(episodeCell.episodeDuration)!.truncatingRemainder(dividingBy: 60)))
                    episodePubDateField.stringValue = "\(dateFormatter.string(from: episodeCell.pubDate)) • \(duration!)"
                }else{
                    duration = String(Int(Double(episodeCell.episodeDuration)! / 60) % 60) + ":" +  String(format: "%02d", Int(Double(episodeCell.episodeDuration)!.truncatingRemainder(dividingBy: 60)))
                    episodePubDateField.stringValue = "\(dateFormatter.string(from: episodeCell.pubDate)) • \(duration!)"
                }
            }else{
                episodePubDateField.stringValue = "\(dateFormatter.string(from: episodeCell.pubDate))"
            }
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(episodeCell.podcastDescription)
            episodeDescriptionField.stringValue = (try doc.text())
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    func showButton(atIndexPaths: Int!){
        playButton.isEnabled = true
        pauseButton.isEnabled = true
        infoButton.isEnabled = true
        episodeSelectedIndex = atIndexPaths
        if playingIndex == episodeSelectedIndex && currentSelectedPodcastIndex == podcastSelecetedIndex{
            playButton.alphaValue = 0
            showPlayPauseAnimation(check: 0)
            
        }else{
            showPlayPauseAnimation(check: 1)
        }
        
    }
    func showPlayPauseAnimation(check: CGFloat){
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 0.5
            infoButton.animator().alphaValue = 1.0
            if playButton.alphaValue == 1{
                playButton.animator().alphaValue = 1 - check
                pauseButton.animator().alphaValue = check
            }else{
                playButton.animator().alphaValue = check
                pauseButton.animator().alphaValue = 1 - check
            }
        }, completionHandler:{
        })
    }
    func hideButton(atIndexPaths: Int!){
        playButton.isEnabled = false
        pauseButton.isEnabled = false
        infoButton.isEnabled = false
        infoButton.alphaValue = 0
        playButton.alphaValue = 0
        pauseButton.alphaValue = 0
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hide"), object: nil)
        
    }
    func playPlayer(){
        player?.play()
        currentSelectedPodcastIndex = podcastSelecetedIndex
        playingIndex = episodeSelectedIndex
        sendNotifications()
        updateSlider()
        observePlayPause()
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhide"), object: nil)
        
        
    }
    
    func sendNotifications(){
        playPauseCheck = 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setBackground"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playPausePass"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playPausePassStatus"), object: nil)
    }
    
    func pausePlayer(){
        player?.pause()
        playPauseCheck = 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playPausePass"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playPausePassStatus"), object: nil)
        
        let duration = player.currentItem!.duration

        if playingIndex == nil{
            if player.currentTime().seconds >= duration.seconds{
                pausedTimes.remove(at: episodeSelectedIndex)
                pausedTimes.insert(CMTime.zero, at: episodeSelectedIndex)
            }else{
                pausedTimes.remove(at: episodeSelectedIndex)
                pausedTimes.insert(player?.currentTime(), at: episodeSelectedIndex)
            }
        }else{
            if player.currentTime().seconds >= duration.seconds{
                pausedTimes.remove(at: playingIndex)
                pausedTimes.insert(CMTime.zero, at: playingIndex)
            }else{
                pausedTimes.remove(at: playingIndex)
                pausedTimes.insert(player?.currentTime(), at: playingIndex)
            }
            
        }
        
        if currentSelectedPodcastIndex == podcastSelecetedIndex{
            pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
        }else{
            pausedTimesDictionary[currentSelectedPodcastIndex] = pausedTimes
        }
        playingIndex = nil
        
    }
    
    /// This method handles the play/pause action by either playing from the start of an episode / pausing episode / seeking to an episode play postion from last stopped time
    @IBAction func playPauseButtonClicked(_ sender: Any) {
        if playingIndex != nil
        {
            if playingIndex == episodeSelectedIndex && currentSelectedPodcastIndex == podcastSelecetedIndex{
                if playButton.alphaValue == 1{
                    if episodeSelectedIndex != nil{
                        player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                        if pausedTimesDictionary[podcastSelecetedIndex]?[episodeSelectedIndex] == nil{
                            //                            currentSelectedPodcastIndex = podcastSelecetedIndex
                            playPlayer()
                        }else{
                            player?.seek(to: pausedTimesDictionary[podcastSelecetedIndex]![playingIndex]!)
                            playPlayer()
                        }
                    }
                    playButton.alphaValue = 0
                    pauseButton.alphaValue = 1
                }else{
                    pausePlayer()
                    playingIndex = nil
                    playButton.alphaValue = 1
                    pauseButton.alphaValue = 0
                }
            }else{
                pausePlayer()
                playingIndex = nil
                playPauseButtonClicked(Any?.self)
                updateSlider()
                observePlayPause()
            }
        }else{
            if playButton.alphaValue == 1{
                if episodeSelectedIndex != nil{
                    player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                    if pausedTimesDictionary[podcastSelecetedIndex]?[episodeSelectedIndex] == nil{
                        playPlayer()
                    }else{
                        playingIndex = episodeSelectedIndex
                        
                        player?.seek(to: pausedTimesDictionary[podcastSelecetedIndex]![playingIndex]!)
                        playPlayer()
                    }
                }
                playButton.alphaValue = 0
                pauseButton.alphaValue = 1
            }else if pauseButton.alphaValue == 1{
                pausePlayer()
                playingIndex = nil
                playButton.alphaValue = 1
                pauseButton.alphaValue = 0
            }
        }
    }
    @objc func seekToPosition(){
        if sliderStop == 0{
            let seekTime = CMTimeMakeWithSeconds(test ?? 0, preferredTimescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
            sliderStop = nil
        }else{
            sliderStop = nil
        }
    }
    
    
    func observePlayPause(){
        circularProgress.isHidden = false
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        //        networkIndicator.startAnimation(Any?.self)
        //        view.addSubview(networkIndicator)
        view.addSubview(circularProgress)
    }
    func updateSlider(){
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            playerSeconds = Float(seconds)
            
            if let duration = player.currentItem?.duration{
                let durationSeconds = CMTimeGetSeconds(duration)
                playerDuration = Float(durationSeconds)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveSlider"), object: nil)
            }
            
        }
    }
    
    /// This method shows the user when a certain episode is buffering 
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    
                    if newStatus == .playing  {
                        self?.circularProgress.isHidden = true
                    } else {
                        self?.circularProgress.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc =  storyboard.instantiateController(withIdentifier: "EpisodeInfoVC") as? NSViewController else { return }
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: infoButton.bounds, of: infoButton, preferredEdge: .maxX)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

