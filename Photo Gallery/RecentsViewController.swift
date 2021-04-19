//
//  RecentViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 18/4/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class RecentsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchingResults()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        images.removeAll()
        collectionView.reloadData()
        fetchingResults()
    }
    
    // MARK: - Model
    private var hits: [hits] = []
    private var images: [UIImage] = []
    private var verticalPage = 1
    private var horizontalPage = 1
    private var urlString: String?
    private var actualCellIndex: Int?
    private var isFetching = false
    
    // MARK: - Fetching images
    private func fetchingResults(){
        
        isFetching = true

        if UIDevice.current.orientation.isPortrait{
            urlString = "https://pixabay.com/api/?key=20876094-2f7e1bc3e385f06c641f33dba&order=latest&safesearch=true&orientation=vertical&page=\(verticalPage)&per_page=50&q="
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
                layout.scrollDirection = .vertical
            }
        } else if UIDevice.current.orientation.isLandscape{
            urlString =  "https://pixabay.com/api/?key=20876094-2f7e1bc3e385f06c641f33dba&orientation=horizontal&safesearch=true&order=latest&page=\(horizontalPage)&per_page=50&q="
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
                layout.scrollDirection = .horizontal
            }
        }
        
        guard let string = urlString else { return }
        
        guard let url = URL(string: string) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else{ return }
            DispatchQueue.main.async {
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            }
            do{
                let jsonResult = try JSONDecoder().decode(Photo.self, from: data)
                self?.hits = jsonResult.hits
                self?.fetchingImages()
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    private let dispatchGroup = DispatchGroup()
    
    private func fetchingImages(){
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
        
        if UIDevice.current.orientation.isPortrait{
            verticalPage += 1
        } else if UIDevice.current.orientation.isLandscape{
            horizontalPage += 1
        }
        
        dispatchGroup.notify(queue: .main, execute: {self.images += newImages ;  self.collectionView?.reloadData(); self.isFetching = false; self.activityIndicator.stopAnimating(); self.activityIndicator.isHidden = true; self.collectionView.flashScrollIndicators() })
    }

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - CollectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as? RecentsCollectionViewCell else { return UICollectionViewCell() }
        
        let image = images[indexPath.row]
        cell.imageView.image = image
        actualCellIndex = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let safeArea = view.safeAreaLayoutGuide.layoutFrame
        let width = safeArea.size.width
        let height = safeArea.size.height
        
        return CGSize(width: width, height: height)
    }
    
    
    //Pagination (infinite scroll)
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let position = scrollView.contentOffset.y
        if position > (collectionView.contentSize.height - 100 - scrollView.frame.size.height){
            if isFetching == false{
                guard let index = actualCellIndex, index == images.count - 1 else { return }
                activityIndicator.activityIndicatorViewStyle = .whiteLarge
                activityIndicator.color = .blue
                fetchingResults()
            }
        }
    }
    
    
    
}
