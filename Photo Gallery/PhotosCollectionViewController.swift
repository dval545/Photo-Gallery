//
//  PhotosCollectionViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 27/3/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        fetchingResults()
    }
    
    var text: String?
    var hits: [hits] = []
    var images: [UIImage?] = []
    
    
    func fetchingResults(){
        let urlString = "https://pixabay.com/api/?key=20876094-2f7e1bc3e385f06c641f33dba&per_page=50&q=\(text ?? "")"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else{ return }
            
            do{
                let jsonResult = try JSONDecoder().decode(Photo.self, from: data)
                self?.hits = jsonResult.hits
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        
        let previewURL = hits[indexPath.row].previewURL
        if cell.imageSaved == false{
            cell.activityIndicator.startAnimating()
            let task = URLSession.shared.dataTask(with: previewURL) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let retrievedImage = UIImage(data: data)
                    guard let image = retrievedImage else { return }
                    cell.image = image
                    self.save(with: image, at: indexPath.row)
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    cell.imageSaved = true
                }
            }
            task.resume()
        } else {
            cell.image = load(at: indexPath.row)
        }
        
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
    
    //Saving images in cache
    func save(with image: UIImage, at indexPathRow: Int){
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
                    print("Saved succesfully")
                }catch let error{
                    print("couldn't save \(error)")
                }
            }
        }
    }
    
    //Loading images from cache
    func load(at indexPathRow: Int) -> UIImage?{
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
