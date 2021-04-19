//
//  PhotoViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 30/3/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(tapGestureRecognizer)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
    }
    
    // MARK: - Inits
    init(whit image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.recievedImage = image
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Variables
    private var imageView = UIImageView()
    var recievedImage: UIImage?{
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.isHidden = true
        return ai
    }()
    
    // MARK: - Override methods
    override func viewWillLayoutSubviews() {
        imageView.frame.size = view.frame.size
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        view.layoutIfNeeded()
        
    }
    
    // MARK: - Tap gesture action
    private var navBarIsHidden = false
    @objc private func tapAction(sender: UITapGestureRecognizer){
        navBarIsHidden = !navBarIsHidden
        navigationController?.navigationBar.isHidden = navBarIsHidden
    }
    

}
