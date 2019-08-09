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

var episodeSelectedIndex: Int!
var playingIndex: Int!
var player: AVPlayer! = nil
var pausedTimes = [CMTime?](repeating: nil, count: episodes.count)
var pausedTimesDictionary = [Int: [CMTime?]]()
var playerSeconds: Float!
var playerDuration: Float!
var currentSelectedPodcastIndex: Int!
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
    
    
    
    let popoverView = NSPopover()
    
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
        let labelYPostion:CGFloat = view.bounds.midY + 15
        let labelWidth:CGFloat = 30
        let labelHeight:CGFloat = 30
        networkIndicator.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        networkIndicator.style = .spinning
//        NotificationCenter.default.addObserver(self, selector: #selector(podcastChanged), name: NSNotification.Name(rawValue: "podcastChanged"), object: nil)
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 2.0 : 0.0
    }
    
//    @objc func podcastChanged(){
//        if playingIndex == episodeSelectedIndex {
//            playButton.alphaValue = 1.0
//            pauseButton.alphaValue = 0.0
//        }
    
//    }
    
    func configureEpisodeCell(episodeCell: Episodes){
        
        episodeTitleField.stringValue = episodeCell.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d, yyyy"
        episodePubDateField.stringValue = "\(dateFormatter.string(from: episodeCell.pubDate)) • \(episodeCell.episodeDuration)"
        do {
            let doc: Document = try SwiftSoup.parse(episodeCell.podcastDescription)
            episodeDescriptionField.stringValue = (try doc.text())
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        

//        episodeDescriptionField.stringValue = episodeCell.podcastDescription
//        podcastDescriptionView.loadHTMLString(episodeCell.podcastDescription, baseURL: nil)
//        podcastDescriptionView.evaluateJavaScript("document.body.innerText") { (string, error) in
//            print(string)
//        }
    }
    func showButton(atIndexPaths: Int!){
        playButton.isEnabled = true
        pauseButton.isEnabled = true
        infoButton.isEnabled = true
        episodeSelectedIndex = atIndexPaths
        
            if playingIndex == episodeSelectedIndex && currentSelectedPodcastIndex == podcastSelecetedIndex{
                playButton.alphaValue = 0
                NSAnimationContext.runAnimationGroup({_ in
                    NSAnimationContext.current.duration = 0.5
                    infoButton.animator().alphaValue = 1.0
                    if playButton.alphaValue == 1{
                        playButton.animator().alphaValue = 1
                        pauseButton.animator().alphaValue = 0
                    }else{
                        playButton.animator().alphaValue = 0
                        pauseButton.animator().alphaValue = 1
                    }
                }, completionHandler:{
                })
            }else{
                NSAnimationContext.runAnimationGroup({_ in
                    NSAnimationContext.current.duration = 0.5
                    infoButton.animator().alphaValue = 1.0
                    if playButton.alphaValue == 1{
                        playButton.animator().alphaValue = 0
                        pauseButton.animator().alphaValue = 1
                    }else{
                        playButton.animator().alphaValue = 1
                        pauseButton.animator().alphaValue = 0
                    }
                }, completionHandler:{
                })
            }

        
//        infoButtonClicked((Any).self)
        
    
    }
    func hideButton(){
        playButton.isEnabled = false
        pauseButton.isEnabled = false
        infoButton.isEnabled = false
        infoButton.alphaValue = 0
        playButton.alphaValue = 0
        pauseButton.alphaValue = 0
        
    }

    @IBAction func playPauseButtonClicked(_ sender: Any) {
//        print(pausedTimesDictionary)
//        print(playingIndex)
//        print(currentSelectedPodcastIndex)
        if playingIndex != nil
        {
            if playingIndex == episodeSelectedIndex && currentSelectedPodcastIndex == podcastSelecetedIndex{
                if playButton.alphaValue == 1{
                    if episodeSelectedIndex != nil{
                        player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                        if pausedTimesDictionary[podcastSelecetedIndex]?[episodeSelectedIndex] == nil{
//                            currentSelectedPodcastIndex = podcastSelecetedIndex
                            player?.play()
                            currentSelectedPodcastIndex = podcastSelecetedIndex
                            updateSlider()
                            observePlayPause()
                            playingIndex = episodeSelectedIndex
                        }else{
                            player?.seek(to: pausedTimesDictionary[podcastSelecetedIndex]![playingIndex]!)
                            player?.play()
                            currentSelectedPodcastIndex = podcastSelecetedIndex
                            updateSlider()
                            observePlayPause()
                            playingIndex = episodeSelectedIndex
                        }
                    }
                    playButton.alphaValue = 0
                    pauseButton.alphaValue = 1
                }else{
                    player?.pause()
                    pausedTimes.remove(at: playingIndex)
                    pausedTimes.insert(player?.currentTime(), at: playingIndex)
                    if currentSelectedPodcastIndex == podcastSelecetedIndex{
                        pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
                    }else{
                        pausedTimesDictionary[currentSelectedPodcastIndex] = pausedTimes
                    }
                    
                    playingIndex = nil
                    playButton.alphaValue = 1
                    pauseButton.alphaValue = 0
                }
            }else{
                player.pause()
                pausedTimes.remove(at: playingIndex)
                pausedTimes.insert(player?.currentTime(), at: playingIndex)
                if currentSelectedPodcastIndex == podcastSelecetedIndex{
                    pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
                }else{
                    pausedTimesDictionary[currentSelectedPodcastIndex] = pausedTimes
                }
                playingIndex = nil
//                playButton.alphaValue = 1
//                pauseButton.alphaValue = 0
                playPauseButtonClicked(Any?.self)
                updateSlider()
                observePlayPause()

            }
 
        }else{
            if playButton.alphaValue == 1{
                if episodeSelectedIndex != nil{
                    player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                    if pausedTimesDictionary[podcastSelecetedIndex]?[episodeSelectedIndex] == nil{
                        player?.play()
                        currentSelectedPodcastIndex = podcastSelecetedIndex
                        updateSlider()
                        observePlayPause()
                        playingIndex = episodeSelectedIndex
                    }else{
                        playingIndex = episodeSelectedIndex
                        player?.seek(to: pausedTimesDictionary[podcastSelecetedIndex]![playingIndex]!)
                        player?.play()
                        currentSelectedPodcastIndex = podcastSelecetedIndex
                        observePlayPause()
                        updateSlider()
                    }
                }
                playButton.alphaValue = 0
                pauseButton.alphaValue = 1
            }else{
                player?.pause()
                pausedTimes.remove(at: playingIndex)
                pausedTimes.insert(player?.currentTime(), at: playingIndex)
                if currentSelectedPodcastIndex == podcastSelecetedIndex{
                    pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
                }else{
                    pausedTimesDictionary[currentSelectedPodcastIndex] = pausedTimes
                }
                playingIndex = nil
                playButton.alphaValue = 1
                pauseButton.alphaValue = 0
            }
        }

    }
    
    func observePlayPause(){
        networkIndicator.isHidden = false
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        networkIndicator.startAnimation(Any?.self)
        view.addSubview(networkIndicator)
    }
    func updateSlider(){
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            playerSeconds = Float(seconds)
            
            if let duration = player.currentItem?.duration{
                let durationSeconds = CMTimeGetSeconds(duration)
                playerDuration = Float(durationSeconds)
//               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveSlider"), object: nil)
            }
            
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in

                    if newStatus == .playing  {
                        print("Hello")
                        self?.networkIndicator.isHidden = true
                    } else {
                        print("Bye")
                        self?.networkIndicator.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: Any) {
//        print(episodeDescriptions[episodeSelectedIndex])
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showInfo"), object: nil)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc =  storyboard.instantiateController(withIdentifier: "EpisodeInfoVC") as? NSViewController else { return }
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: infoButton.bounds, of: infoButton, preferredEdge: .maxX)
    }
    
}
