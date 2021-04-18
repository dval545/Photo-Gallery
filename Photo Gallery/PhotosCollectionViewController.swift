//
//  PhotosCollectionViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 27/3/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.title = "Photos"
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
        
        fetchingResults()
    }
    
    // MARK: - Model
    var text: String?
    var hits: [hits] = []
    var images: [UIImage] = []
    var page = 1
    var recivedIndex: Int?
    var order = "popular"
    var orientation = "all"
    
    // MARK: - Fetching images
    
    var isFetching = false
    
    func fetchingResults(){
        
        isFetching = true
        let urlString = "https://pixabay.com/api/?key=20876094-2f7e1bc3e385f06c641f33dba&orientation=\(orientation)&order=\(order)&safesearch=true&page=\(page)&per_page=50&q=\(text ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else{ return }
            DispatchQueue.main.async {
                if self?.page == 1 {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                }
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
        
        dispatchGroup.notify(queue: .main, execute: {self.images += newImages ;  self.collectionView?.reloadData(); self.isFetching = false; self.page += 1; self.activityIndicator.stopAnimating(); self.activityIndicator.isHidden = true })
    }


    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Collection view methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        let image = images[indexPath.row]
        cell.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isPortrait{
            let width = view.frame.size.width / 4 - 1
            let height = view.frame.size.width / 4 - 1
            
            return CGSize(width: width, height: height)
        } else{
            let safeArea = view.safeAreaLayoutGuide
            let size = safeArea.layoutFrame.size
            let width = size.width / 6 - 1
            let height = size.width / 6 - 1
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterCollectionReusableView", for: indexPath) as! FooterCollectionReusableView
        if page > 1 {
            footer.activityIndicator?.isHidden = false 
            footer.activityIndicator?.startAnimating()
        } else {
            footer.activityIndicator?.stopAnimating()
            footer.activityIndicator?.isHidden = true
        }
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 100)
    }
    
    var scrolledToIndex = false
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let index = recivedIndex else { return }
        if index < images.count{
            if !scrolledToIndex{
                let indexToScrollTo = IndexPath(item: index, section: 0)
                self.collectionView.scrollToItem(at: indexToScrollTo, at: .bottom, animated: false)
                scrolledToIndex = true
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    // MARK: -  Pagination (infinite scroll)
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let position = scrollView.contentOffset.y
        if position > (collectionView.contentSize.height - 100 - scrollView.frame.size.height){
            if isFetching == false{
                fetchingResults()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoSegue"{
            let cell = sender as! ImageCollectionViewCell
            //guard let image = cell.image else { return }
            let indexPath = collectionView.indexPath(for: cell)
            guard let index = indexPath?.item else { return }
            
            let photosPageVC = segue.destination as? PhotosPageViewController
            photosPageVC?.hits = hits
            photosPageVC?.index = index
            photosPageVC?.images = images
            photosPageVC?.text = text
            photosPageVC?.order = order
            photosPageVC?.orientation = orientation
            photosPageVC?.page = page 
        } else if segue.identifier == "FilterSegue"{
            let filterTableViewController = segue.destination as? FilterTableViewController
            
            filterTableViewController?.order = order
            filterTableViewController?.orientation = orientation
        }
    }
    
    @IBAction func unwindToPhotosCollectionViewController(segue: UIStoryboardSegue){
        if segue.identifier == "Done"{
            let filterTableViewController = segue.source as! FilterTableViewController
            
            order = filterTableViewController.order
            orientation = filterTableViewController.orientation
            page = filterTableViewController.page
            hits.removeAll()
            images.removeAll()
            collectionView.reloadData()
            fetchingResults()
            
        } 
    }
    

}
