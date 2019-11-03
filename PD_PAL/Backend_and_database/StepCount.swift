//
//  StepCounter.swift
//  PD_PAL
//
// This file implements step counter using the CMPedometer
//
//  Created by Julia Kim on 2019-10-28.
//  Copyright © 2019 WareOne. All rights reserved.
//

/*Revision History
 
 -28/10/2019: Julia Kim
    Created file, implemented CMPedometer, added "Privacy - Motion Usage Description" to Info.plist to ask for user permission
 -29/10/2019: Julia Kim
    Separated live updates and querying data history
 -30/10/2019: Julia Kim
    Tested with a real device to ensure that user permission is asked upon the first time launch of the app and that steps are counted.
 -2/11/2019: Julia Kim
    Refactoring + adding comments
 */

import CoreMotion //to utilize CMPedometer
import Foundation
import Dispatch //only if we want to execute code concurrently on multicore hardware by submitting work to dispatch queues managed by the system.


//create pedometer
class StepCount{
    
    var pedometer = CMPedometer() //instance of CMPedometer class
    var getHistory = false
    var date = Date() //initialize to the current date
    
    //see if specific date was selected
    //need to finish this function for version 2
    @IBAction func dateBtnSelected() -> Void{
        getHistory = true
        //date = //date specified by user
    }
    
    //This function determines if user requested to see the step data for specific dates or live data
    func track_steps(){
        //check if step counting data is available
        if CMPedometer.isStepCountingAvailable() {
            
            if getHistory //to be triggered by trends page later when viewing history
            {
                   //for version 2
                   //query step counter data
                    query_steps(date: date) //need to pass in the date selected by the user for version 2
            }
            else
            {
                  //get live updates
                  live_updates() //only get live updates for version 1
            }
        }
    }
    
    //This function allows tracking of user step data and adds that data to the DB
    func live_updates(){
        /* This function was written using the following source with minor changes.
         Source: wysockikamil.com/coremotion-pedometer-swift */
        //var dateString = date_format()
        //Date() gets the current date
        pedometer.startUpdates(from: Date()) { pedometerData, error in
                guard let pedData = pedometerData, error == nil else {return}
            DispatchQueue.main.async{
                //extract current hour, day, month and year to prepare for DB insertion
                let year = Calendar.current.component(.year, from: Date())
                let month = Calendar.current.component(.month, from: Date())
                let day = Calendar.current.component(.day, from: Date())
                let hour = Calendar.current.component(.hour, from: Date())
                
                print(Date())
                print("Year: \(year)")
                print("Month: \(month)")
                print("Day: \(day)")
                
                //update # of steps taken by incrementing
                global_UserData.Increment_Steps_Taken(Steps: Int64(pedData.numberOfSteps), YearDone: year, MonthDone: month, DayDone: day, HourDone: hour)
                
                print("Steps from DB: \(global_UserData.Get_Steps_Taken(TargetYear: year, TargetMonth: month, TargetDay: day, TargetHour: hour))")
                }
            }
    }
    
    
    //This function allows user to query steps for specified date
    //this is for version 2
    func query_steps(date: Date){
        //to used for version2
        /* This function was written using the following source with minor changes.
         Source: wysockikamil.com/coremotion-pedometer-swift */
       //query step data for specified date from the database
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let hour = Calendar.current.component(.hour, from: date)
        
        //print the number of steps taken for the date selected
        print(global_UserData.Get_Steps_Taken(TargetYear: year, TargetMonth: month, TargetDay: day, TargetHour: hour))
        
    }
  
}


