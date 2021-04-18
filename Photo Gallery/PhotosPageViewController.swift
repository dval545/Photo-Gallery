//
//  PhotosPageViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 4/4/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class PhotosPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UINavigationControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        navigationController?.delegate = self
        
        navigationItem.title = text ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: { self.addingVCs() })
    }
    
    
    // MARK: - Model
    var hits: [hits] = []
    var text: String?
    var order: String?
    var orientation: String?
    var page: Int?
    var images = [UIImage]()
    var index: Int?
    var photoVC = [PhotoViewController]()

    //MARK: - Fetching images
    func fetchingResults(){
        
        let urlString = "https://pixabay.com/api/?key=20876094-2f7e1bc3e385f06c641f33dba&orientation=\(orientation ?? "all")&order=\(order ?? "popular")&page=\(page ?? 1)&per_page=50&q=\(text ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else{ return }
            do{
                let jsonResult = try JSONDecoder().decode(Photo.self, from: data)
                self?.hits = jsonResult.hits
                self?.fetchingImages()
                /*DispatchQueue.main.async {
                 self?.collectionView?.reloadData()
                 }*/
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    let dispatchGroup = DispatchGroup()
    
    func fetchingImages(){
        var newImages = [UIImage]()
        for hit in hits{
            dispatchGroup.enter()
            
            let task = URLSession.shared.dataTask(with: hit.largeImageURL, completionHandler: { [ weak self] data, response, error in
                defer{
                    self?.dispatchGroup.leave()
                }
                guard let data = data, error == nil else { return }
                let retrievedImage = UIImage(data: data)
                guard let image = retrievedImage else { return }
                newImages.append(image)
            })
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main, execute: { self.images += newImages; self.addingVCs(); self.page? += 1 })
    }

    // MARK: - Adding and presenting VCs
    func addingVCs(){
        photoVC.removeAll()
        for image in images{
            let vc = PhotoViewController(whit: image)
            photoVC.append(vc)
        }
        let vc = PhotoViewController()
        vc.activityIndicator.isHidden = false
        vc.activityIndicator.startAnimating()
        photoVC.append(vc)
        presentVC()
    }
    
    func presentVC(){
        guard let index = index else { return }
        let vc = photoVC[index]
        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        
    }
    
    
    // MARK: - PageViewController methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = photoVC.index(of: viewController as! PhotoViewController), index > 0 else { return nil }
        let before = index - 1
        
        return photoVC[before]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = photoVC.index(of: viewController as! PhotoViewController), index < photoVC.count - 1 else {
           return nil
        }
    
        
        let after = index + 1
        
        if after == photoVC.count - 1{
            fetchingResults()
        }
        
        self.index = after
        return photoVC[after]
    }
    
    // MARK: - Navigation
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let photosCollectionVC = viewController as? PhotosCollectionViewController
        photosCollectionVC?.images = images
        photosCollectionVC?.page = page!
        photosCollectionVC?.recivedIndex = index!
        photosCollectionVC?.scrolledToIndex = false
        photosCollectionVC?.collectionView.reloadData()
    }
    

}
