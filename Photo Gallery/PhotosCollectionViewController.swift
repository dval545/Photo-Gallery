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
        tabBarController?.tabBar.isHidden = true
        fetchingResults()
    }
    
    // MARK: Model
    var text: String?
    var hits: [hits] = []
    var urls = [URL]()
    var images: [UIImage] = []
    var page = 1
    
    // MARK: Fetching images
    
    var isFetching = false
    
    func fetchingResults(){
        
        isFetching = true
        let urlString = "https://pixabay.com/api/?key=20876094-2f7e1bc3e385f06c641f33dba&page=\(page)&per_page=50&q=\(text ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else{ return }
            DispatchQueue.main.async {
                if self?.page == 1 {
                    self?.activityIndicator.startAnimating()
                }
            }
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
        for hit in hits{
            dispatchGroup.enter()
            
            let task = URLSession.shared.dataTask(with: hit.largeImageURL, completionHandler: { [ weak self] data, response, error in
                defer{
                    self?.dispatchGroup.leave()
                }
                guard let data = data, error == nil else { return }
                let retrievedImage = UIImage(data: data)
                guard let image = retrievedImage else { return }
                self?.images.append(image)
            })
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main, execute: { self.collectionView?.reloadData(); self.isFetching = false; self.page += 1; self.activityIndicator.stopAnimating(); self.activityIndicator.isHidden = true })
    }


    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Collection view methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        let image = images[indexPath.row]
        cell.image = image
        
        /*let previewURL = hits[indexPath.row].previewURL
        if cell.imageSaved == false{
            cell.activityIndicator.startAnimating()
            let task = URLSession.shared.dataTask(with: previewURL) { [weak self] data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let retrievedImage = UIImage(data: data)
                    guard let image = retrievedImage else { return }
                    cell.image = image
                    self?.images.append(image)
                    self?.save(with: image, at: indexPath.row)
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    cell.imageSaved = true
                }
            }
            task.resume()
        } else {
            cell.image = load(at: indexPath.row)
        }*/
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    //Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (collectionView.contentSize.height - 100 - scrollView.frame.size.height){
            if isFetching == false{
                fetchingResults()
            }
        }
    }
    
    // MARK: Caching images
    //Saving images in cache
    /*func save(with image: UIImage, at indexPathRow: Int){
        let dataSaved = UIImagePNGRepresentation(image)
        guard let data = dataSaved else { return }
        let imageData = ImageData(data: data)
        if let json = imageData.json{
            if let url = try? FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true).appendingPathComponent("Image\(indexPathRow).json"){
                do{
                    try json.write(to: url)
                    print("Saved succesfully \(indexPathRow)")
                }catch let error{
                    print("couldn't save \(error)")
                }
            }
        }
    }*/
    
    //Loading images from cache
    /*func load(at indexPathRow: Int) -> UIImage?{
        if let url = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true).appendingPathComponent("Image\(indexPathRow).json"){
            if let jsonData = try? Data(contentsOf: url){
                let imageData = ImageData(json: jsonData)
                guard let retrievedData = imageData?.data else { return nil }
                let retrievedImage = UIImage(data: retrievedData)
                guard let image = retrievedImage else { return nil }
                print("Loaded")
                return image
            }else{
                print("Not loaded")
            }
        }
        return nil
    }*/
    
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
            photosPageVC?.urls = urls
        }
    }
    

}
