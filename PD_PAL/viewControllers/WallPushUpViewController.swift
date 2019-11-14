//
//  WallPushUpViewController.swift
//  PD_PAL
//
//  Created by avafadar on 2019-10-31.
//  Copyright © 2019 WareOne. All rights reserved.
//

import UIKit

class WallPushUpViewController: UIViewController {
    
    // IBOutlet Labels

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    //@IBOutlet weak var viewButton: UIButton!
    
    /* code in here will execute based Global.flag value */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // we came from routines
        if Global.flag == 1 {
            let skipButton = UIButton()
            skipButton.setTitle("Skip",for: .normal)
            skipButton.setTitleColor(.red , for: .normal) //change colour later
            skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
            skipButton.frame = CGRect(x: 25, y: 550, width: 50, height: 100)
            self.view.addSubview(skipButton)

        }
            
        // we came from categories
        else if Global.flag == 2 {
            let startButton = UIButton(frame: CGRect.zero)
            startButton.startButtonDesign()
            self.view.addSubview(startButton)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Global.color_schemes.m_bgColor  // background color
        
        /* navigation bar stuff */
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // remove back button
        //self.navigationController?.navigationBar.barTintColor = Global.color_schemes.m_blue1                      // nav bar color
        self.title = nil                                                                                            // no page title

        // page message
        self.show_page_message(s1: "WALL PUSH-UP", s2: "WALL PUSH-UP")
        
        // read exercise info into labels
        let readResult = global_ExerciseData.read_exercise(NameOfExercise: "WALL PUSH-UP")
        
        // exercise description and duration text
        self.show_exercise_description(string: readResult.Description)
        //self.show_exercise_duration(string: readResult.Duration)
        
        // view button
        //viewButton.viewButtonDesign()
        //applyViewButtonConstraints(button: viewButton)

        // home button on navigation bar
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
        self.navigationItem.rightBarButtonItem  = homeButton
        
        image.image = UIImage(named: "pushup_step1.png")
        image2.image = UIImage(named: "pushup_step2.png")
    }
    
    // called when home button on navigation bar is tapped
    @objc func homeButtonTapped(sender: UIButton!) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "mainNavVC")
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @objc func selectButtonTapped(sender: UIButton!) {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let hour = Calendar.current.component(.hour, from: Date())
        
        // insert excercise as done
        global_UserData.Add_Exercise_Done(ExerciseName: "WALL PUSH-UP", YearDone: year, MonthDone: month, DayDone: day, HourDone: hour)
    }
    
    
    @objc func skipButtonTapped()
    {
        //let nextExercise = Name of viewController for exercise
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "mainNavVC")
        self.present(newViewController, animated: true, completion: nil)
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


