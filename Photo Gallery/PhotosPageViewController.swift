//
//  PhotosPageViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 4/4/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class PhotosPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: { self.addingVCs() })
    }
    
    var hits: [hits] = []
    var urls = [URL]()
    var url: URL?
    var images = [UIImage]()
    var index: Int?
    var currentVCIndex: Int?
    var photoVC = [PhotoViewController]()
    
    func addingVCs(){
        for image in images{
            let vc = PhotoViewController(whit: image)
            photoVC.append(vc)
        }
        presentVC()
    }
    
    func presentVC(){
        guard let index = index else { return }
        let vc = photoVC[index]
        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = photoVC.index(of: viewController as! PhotoViewController), index > 0 else { return nil }
        let before = index - 1
        
        currentVCIndex = before
        return photoVC[before]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = photoVC.index(of: viewController as! PhotoViewController), index < photoVC.count - 1 else { return nil }
        
        let after = index + 1
        currentVCIndex = after
        return photoVC[after]
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard let index = currentVCIndex else { return nil }
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        scrollView.addSubview(photoVC[index].imageView)
        return photoVC[index].imageView
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
