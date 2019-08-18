//
//  AppDelegate.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

var yHeight : CGFloat!
var xWidth : CGFloat!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 1), styleMask: .borderless, backing: .buffered, defer: false)
    private var playerController: NSWindowController? = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "playerViewController") as? NSWindowController


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        statusItem.button?.image = NSImage(named: "icon")
        statusItem.button?.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        statusItem.button?.action = #selector(AppDelegate.statusBarButtonClicked(_ :))
        
        invisibleWindow.backgroundColor = .clear
        invisibleWindow.alphaValue = 0
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc =  storyboard.instantiateController(withIdentifier: "StatusBarVC") as? NSViewController else { return }
        playerController?.contentViewController = vc
        playerController?.window?.isOpaque = false
        playerController?.window?.backgroundColor = .clear
        playerController?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
    }
    
    
    @objc func statusBarButtonClicked(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEvent.EventType.leftMouseUp
        {
            if playerController?.window?.isVisible == true
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
                playerController?.close()
            }else{
                displayPopUp()
            }
            
        }else if event.type == NSEvent.EventType.rightMouseUp{
            
            var appVersion: String? {
                return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            }
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Newcast version \(appVersion ?? "")", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Newcast", action: #selector(self.quitApp), keyEquivalent: "q"))
            
            statusItem.popUpMenu(menu)
            
            
        }
    }
    @objc func quitApp()
    {
        NSApp.terminate(self)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func addNewPodcastClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "search"), object: nil)
        
    }
    @IBAction func findPodcastClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchSavedPodcast"), object: nil)
    }
    
    func displayPopUp() {
        let rectWindow = statusItem.button?.window?.convertToScreen((statusItem.button?.frame)!)
        let menubarHeight = rectWindow?.height ?? 22
        let height = playerController?.window?.frame.height ?? 300
        let xOffset = ((playerController?.window?.contentView?.frame.midX)! - (statusItem.button?.frame.midX)!)
        let x = (rectWindow?.origin.x)! - xOffset
        xWidth = x
        let y = (rectWindow?.origin.y)!
        yHeight = y-height+menubarHeight - 65
        playerController?.window?.setFrameOrigin(NSPoint(x: x, y: y+menubarHeight-height))
        playerController?.showWindow(self)
        
    }
    
}

