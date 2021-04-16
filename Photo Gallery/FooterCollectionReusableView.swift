//
//  FooterCollectionReusableView.swift
//  Photo Gallery
//
//  Created by Admin1 on 11/4/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator?.center = self.center
    }
    
}
