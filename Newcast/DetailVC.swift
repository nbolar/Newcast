//
//  DetailVC.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa
import SDWebImage
import AVFoundation
import CircularProgressMac

var podcastSelecetedIndex : Int!
var seekToPosition: Float64!

class DetailVC: NSViewController {

    @IBOutlet weak var scrollingTextView: ScrollingTextView!
    @IBOutlet weak var playerInfo: NSTextField!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var skip30ForwardButton: NSButton!
    @IBOutlet weak var skip30BackButton: NSButton!
    @IBOutlet weak var playerSlider: NSSlider!
    @IBOutlet weak var episodesPlaceholderField: NSTextField!
    @IBOutlet weak var podcastImageView: SDAnimatedImageView!
    @IBOutlet weak var podcastTitleField: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var playerCustomView: NSView!
    @IBOutlet weak var backgroundImageView: NSImageView!
    var playPauseCheck: Int! = 0
    let networkIndicator = NSProgressIndicator()
    let popoverView = NSPopover()
    let circularProgress = CircularProgress(size: 60)
    var deleted: Bool!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        collectionView.deselectAll(Any?.self)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: NSNotification.Name(rawValue: "updateTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEpisodes), name: NSNotification.Name(rawValue: "updateEpisodes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deletedPodcast), name: NSNotification.Name(rawValue: "deletedPodcast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deletedPodcast), name: NSNotification.Name(rawValue: "clearPodcastEpisodes"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveSlider), name: NSNotification.Name(rawValue: "moveSlider"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playPausePass), name: NSNotification.Name(rawValue: "playPausePass"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideUI), name: NSNotification.Name(rawValue: "hide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unhideUI), name: NSNotification.Name(rawValue: "unhide"), object: nil)
        
        setupUI()
        playPauseCheck = 0
    }
    
    func setupUI(){
        view.insertVibrancyView(material: .hudWindow)
        networkIndicator.style = .spinning
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.wantsLayer = true
        collectionView.layer?.cornerRadius = 8
        backgroundImageView.alphaValue = 0.6
        playerCustomView.wantsLayer = true
        playerCustomView.layer?.backgroundColor = CGColor.init(gray: 0.9, alpha: 0.2)
        playerCustomView.layer?.cornerRadius = 8
        playerCustomView.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        podcastImageView.image = nil
        podcastImageView.wantsLayer = true
        podcastImageView.layer?.cornerRadius = 8
        podcastImageView.alphaValue = 0.9
        podcastImageView.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        podcastTitleField.stringValue = ""
        scrollingTextView.setup(string: "")
        episodesPlaceholderField.alphaValue = 0
        playerSlider.isHidden = true
        playPauseButton.isHidden = true
        skip30BackButton.isHidden = true
        skip30ForwardButton.isHidden = true
        
        
        
//        let labelXPostion:CGFloat = view.bounds.midX
//        let labelYPostion:CGFloat = view.bounds.midY
//        let labelWidth:CGFloat = 30
//        let labelHeight:CGFloat = 30
//        networkIndicator.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        
        circularProgress.isIndeterminate = true
        circularProgress.color = .white
        let labelXPostion:CGFloat = 350
        let labelYPostion:CGFloat = 253
        let labelWidth:CGFloat = 60
        let labelHeight:CGFloat = 60
        circularProgress.frame = CGRect(x: labelXPostion, y: labelYPostion, width: labelWidth, height: labelHeight)
        
//        view.addSubview(circularProgress)
    }
    
    @objc func hideUI(){
        playerSlider.isHidden = true
        playPauseButton.isHidden = true
        skip30BackButton.isHidden = true
        skip30ForwardButton.isHidden = true
//        playerInfo.stringValue = ""
    }
    @objc func unhideUI(){
        playerSlider.isHidden = false
        playPauseButton.isHidden = false
        skip30BackButton.isHidden = false
        skip30ForwardButton.isHidden = false
        
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
    
    @IBAction func musicSliderPositionChanged(_ sender: Any) {
        test = playerSlider.doubleValue
        sliderStop = 0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sliderChanged"), object: nil)
    }
    
    @objc func playPausePass(){
        if playPauseButton.image?.name() == "play"{
            scrollingTextView.setup(string: "\(podcastsTitle[podcastSelecetedIndex]) — \(episodeTitles[playingIndex])")
            scrollingTextView.speed = 4
            view.addSubview(scrollingTextView)
            playPauseButton.image = NSImage(named: "pause")
        }else{
            scrollingTextView.speed = 0
            scrollingTextView.setup(string: "\(podcastsTitle[podcastSelecetedIndex]) — \(episodeTitles[playingIndex])")
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
    func highlightItems(selected: Bool, atIndexPaths: Set<NSIndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath as IndexPath) else {continue}
            (item as! EpisodeCellView).setHighlight(selected: selected)
            if selected == true{
                (item as! EpisodeCellView).showButton(atIndexPaths: indexPath.item)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "podcastChanged"), object: nil)
                unhideUI()
            }
            if selected == false{
                (item as! EpisodeCellView).hideButton(atIndexPaths: indexPath.item)
            }
            
        }
    }
    
    @objc func updateEpisodes(){
        let area = NSTrackingArea.init(rect: podcastImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        podcastImageView.addTrackingArea(area)
        collectionView.reloadData()
//        networkIndicator.removeFromSuperview()
        circularProgress.removeFromSuperview()
        episodesPlaceholderField.alphaValue = 1.0
        collectionView.deselectAll(Any?.self)
        collectionView.reloadData()
    }
    @objc func updateTitle(){
        if playingIndex != nil{
            unhideUI()
        }
        
        let area = NSTrackingArea.init(rect: podcastImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        podcastImageView.addTrackingArea(area)
        podcastTitleField.stringValue = "\(podcastsTitle[podcastSelecetedIndex])"
        podcastImageView.sd_setImage(with: URL(string: podcastsImageURL[podcastSelecetedIndex]), placeholderImage: NSImage(named: "placeholder"), options: .init(), context: nil)
        collectionView.reloadData()
//        networkIndicator.startAnimation(Any?.self)
//        view.addSubview(networkIndicator)
        view.addSubview(circularProgress)
    }
    
    @objc func deletedPodcast(){
        let area = NSTrackingArea.init(rect: podcastImageView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        podcastImageView.removeTrackingArea(area)
        collectionView.deselectAll(Any?.self)
        podcastImageView.image = nil
        podcastTitleField.stringValue = ""
        episodesPlaceholderField.alphaValue = 0
        playerSlider.isHidden = true
        playPauseButton.isHidden = true
        skip30BackButton.isHidden = true
        skip30ForwardButton.isHidden = true
        scrollingTextView.setup(string: "")
        episodes.removeAll()
        collectionView.reloadData()
    }
    
    override func mouseEntered(with event: NSEvent) {
        displayPopUp()
        
    }
    
    override func mouseExited(with event: NSEvent) {
        if popoverView.isShown{
            popoverView.close()

        }
    }
    
    func displayPopUp(){
//        print(podcastDescription)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc =  storyboard.instantiateController(withIdentifier: "PodcastDescriptionVC") as? NSViewController else { return }
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: podcastImageView.bounds, of: podcastImageView, preferredEdge: .maxX)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension DetailVC: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let forecastItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EpisodeCellView"), for: indexPath)
        
        guard let forecastCell = forecastItem as? EpisodeCellView else { return forecastItem}
        forecastCell.configureEpisodeCell(episodeCell: episodes[indexPath.item])
        
        return forecastCell
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 680, height: 150)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectAll(Any?.self)
        highlightItems(selected: false, atIndexPaths: indexPaths as Set<NSIndexPath>)
    }

    
    
}
