//
//  CardioViewController.swift
//  PD_PAL
//
//  Created by SpenC on 2019-10-26.
//  Copyright © 2019 WareOne. All rights reserved.
//

// REVISION HISTORY:
// <Date, Name, Changes made>
// <Oct. 26, 2019, Spencer Lall, added exercise buttons


import UIKit

class CardioViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var walking: UIButton!
    @IBOutlet weak var Running: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Setup.m_bgColor

        // PD_PAL header top right of screen
        let label = UILabel(frame: CGRect.zero)
        label.text = "PD_PAL"
        label.textAlignment = .center                                           // text alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(20)                                    // font size
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 100),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),   // 15 points left of right view anchor
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: -10),         // 10 points below top of view
            ])
        
        // back button
        backButton.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        backButton.setTitle("Back", for: UIControl.State.normal)
        self.view.addSubview(backButton)
        
        // Page Name
        let pageName = UILabel(frame: CGRect.zero)
        pageName.text = "CARDIO"
        pageName.textAlignment = .center                                           // text alignment
        pageName.translatesAutoresizingMaskIntoConstraints = false
        pageName.font = UIFont(name:"HelveticaNeue-Bold", size: 30.0)
        self.view.addSubview(pageName)
        
        NSLayoutConstraint.activate([
            pageName.widthAnchor.constraint(equalToConstant: 300),
            pageName.heightAnchor.constraint(equalToConstant: 50),
            pageName.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: 115),   // 15 points left of right view anchor
            pageName.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),         // 10 points below top of view
            ])

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
