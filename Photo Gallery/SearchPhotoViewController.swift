//
//  ViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 26/3/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class SearchPhotoViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.layer.cornerRadius = 3.0
        searchTextField.enablesReturnKeyAutomatically = true
        searchTextField.delegate = self
    }

    
    @IBOutlet private weak var searchTextField: UITextField!

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PCVC") as! PhotosCollectionViewController
        vc.text = searchTextField.text ?? ""
        show(vc, sender: textField)
        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        searchTextField.text = ""
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue"{
            let PCVC = segue.destination as? PhotosCollectionViewController
            
            PCVC?.text = searchTextField.text ?? ""
            
        } 
        
    }
    
}

