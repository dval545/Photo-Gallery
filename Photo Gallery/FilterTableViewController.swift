//
//  FilterTableViewController.swift
//  Photo Gallery
//
//  Created by Admin1 on 14/4/21.
//  Copyright © 2021 Admin1. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if order == "popular"{
            popularSwicth.isOn = true
        } else {
            popularSwicth.isOn = false
            latestSwitch.isOn = true
        }
        
        if orientation == "all"{
            verticalSwitch.isOn = true
            horizontalSwitch.isOn = true
        } else if orientation == "vertical"{
            verticalSwitch.isOn = true
            horizontalSwitch.isOn = false
        } else {
            horizontalSwitch.isOn = true
            verticalSwitch.isOn = false
        }
    }


    @IBOutlet weak var popularSwicth: UISwitch!
    @IBOutlet weak var latestSwitch: UISwitch!
    @IBOutlet weak var verticalSwitch: UISwitch!
    @IBOutlet weak var horizontalSwitch: UISwitch!
    
    var order = "popular"
    var orientation = "all"
    var page = 1
    
    @IBAction func switchSelected(_ sender: UISwitch) {
        switch sender {
        case popularSwicth:
            if popularSwicth.isOn == true{
                latestSwitch.isOn = false
                order = "popular"
            } else if popularSwicth.isOn == false{
                latestSwitch.isOn = true
                order = "latest"
            }
        case latestSwitch:
            if latestSwitch.isOn == true{
                popularSwicth.isOn = false
                order = "latest"
            } else if latestSwitch.isOn == false{
                popularSwicth.isOn = true
                order = "popular"
            }
        case verticalSwitch:
            if horizontalSwitch.isOn == false{
                horizontalSwitch.isOn = true
            }
        case horizontalSwitch:
            if verticalSwitch.isOn == false{
                verticalSwitch.isOn = true
            }
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "Done" else { return }
        if verticalSwitch.isOn == true && horizontalSwitch.isOn == false {
            orientation = "vertical"
        } else if horizontalSwitch.isOn == true && verticalSwitch.isOn == false {
            orientation = "horizontal"
        }
    }

}
