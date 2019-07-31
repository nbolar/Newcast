//
//  Parser.swift
//  Newcast
//
//  Created by Nikhil Bolar on 7/31/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Foundation
import SWXMLHash


class Parser {
    
    func getPodcastMetaData(_ APIData: Data){
        let xml = SWXMLHash.parse(APIData)
        if let title = (xml["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text){
            print(title)
        }
    }
}
