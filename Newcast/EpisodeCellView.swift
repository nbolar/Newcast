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

var episodeSelectedIndex: Int!
class EpisodeCellView: NSCollectionViewItem {

    
    
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var infoButton: NSButton!
    @IBOutlet weak var episodeDescriptionField: NSTextField!
    @IBOutlet weak var episodePubDateField: NSTextField!
    @IBOutlet weak var episodeTitleField: NSTextField!
    var tag = 0
    
    let popoverView = NSPopover()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tag = 0
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
        if playButton.alphaValue == 1{
            playButton.alphaValue = 0
            pauseButton.alphaValue = 1
        }else{
            playButton.alphaValue = 1
            pauseButton.alphaValue = 0
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
