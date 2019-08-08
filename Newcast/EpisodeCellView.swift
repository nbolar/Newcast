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
class EpisodeCellView: NSCollectionViewItem {

    
    
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var infoButton: NSButton!
    @IBOutlet weak var episodeDescriptionField: NSTextField!
    @IBOutlet weak var episodePubDateField: NSTextField!
    @IBOutlet weak var episodeTitleField: NSTextField!
    
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
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 2.0 : 0.0
    }
    
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
        if playingIndex == episodeSelectedIndex{
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
        if playingIndex != nil
        {
            if playingIndex == episodeSelectedIndex{
                if playButton.alphaValue == 1{
                    if episodeSelectedIndex != nil{
                        player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                        if pausedTimesDictionary[podcastSelecetedIndex]?[episodeSelectedIndex] == nil{
                            player?.play()
                            playingIndex = episodeSelectedIndex
                        }else{
                            player?.seek(to: pausedTimesDictionary[podcastSelecetedIndex]![playingIndex]!)
                            player?.play()
                            playingIndex = episodeSelectedIndex
                        }
                    }
                    playButton.alphaValue = 0
                    pauseButton.alphaValue = 1
                }else{
                    player?.pause()
                    pausedTimes.remove(at: playingIndex)
                    pausedTimes.insert(player?.currentTime(), at: playingIndex)
                    pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
                    playingIndex = nil
                    playButton.alphaValue = 1
                    pauseButton.alphaValue = 0
                }
            }else{
                player.pause()
                playingIndex = nil
                pausedTimes.remove(at: playingIndex)
                pausedTimes.insert(player?.currentTime(), at: playingIndex)
                pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
                playButton.alphaValue = 0
                pauseButton.alphaValue = 1
                player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                playingIndex = episodeSelectedIndex
                player.play()

            }
 
        }else{
            if playButton.alphaValue == 1{
                if episodeSelectedIndex != nil{
                    player = AVPlayer(url: URL(string: episodesURL[episodeSelectedIndex])!)
                    if pausedTimesDictionary[podcastSelecetedIndex]?[episodeSelectedIndex] == nil{
                        player?.play()
                        playingIndex = episodeSelectedIndex
                    }else{
                        playingIndex = episodeSelectedIndex
                        player?.seek(to: pausedTimesDictionary[podcastSelecetedIndex]![playingIndex]!)
                        player?.play()
                    }
                }
                playButton.alphaValue = 0
                pauseButton.alphaValue = 1
            }else{
                player?.pause()
                pausedTimes.remove(at: playingIndex)
                pausedTimes.insert(player?.currentTime(), at: playingIndex)
                pausedTimesDictionary[podcastSelecetedIndex] = pausedTimes
                playingIndex = nil
                playButton.alphaValue = 1
                pauseButton.alphaValue = 0
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
