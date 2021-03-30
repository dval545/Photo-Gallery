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


//Added persistence 
struct hits: Codable{
    var previewURL: URL
    var largeImageURL: URL
    
}

struct ImageData: Codable{
    var data: Data
    
    var json: Data?{
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageData.self, from: json){
            self = newValue
        } else{
            return nil
        }
    }
    
    init(data: Data) {
        self.data = data
    }
}

