//
//  AppDelegate.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        statusItem.button?.title = "--"
        statusItem.button?.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        statusItem.button?.action = #selector(AppDelegate.statusBarButtonClicked(_ :))
    }
    
    
    @objc func statusBarButtonClicked(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEvent.EventType.leftMouseUp
        {
           displayPopUp()
            
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
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc =  storyboard.instantiateController(withIdentifier: "StatusBarVC") as? NSViewController else { return }
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)
        
    }
    
}

