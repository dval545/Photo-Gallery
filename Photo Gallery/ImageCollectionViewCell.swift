//
//  ImageCollectionViewCell.swift
//  Photo Gallery
//
//  Created by Admin1 on 27/3/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?{
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
    }
    
    
}
