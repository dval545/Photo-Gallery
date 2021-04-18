//
//  Photo.swift
//  Photo Gallery
//
//  Created by Admin1 on 26/3/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import Foundation

struct Photo: Codable{
    var hits: [hits]
    
}


struct hits: Codable{
    var previewURL: URL
    var largeImageURL: URL
    
}


