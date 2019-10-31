//
//  UserData.swift
//  PD_PAL
//
//  This file implements an object to store and manipulate data created by or related to the user.
//  The database implementation is copied from ExerciseDatabase.swift
//
//  Created by whuong on 2019-10-31.
//  Copyright © 2019 WareOne. All rights reserved.
//

/*
 Revision History
 
 - 31/10/2019 : William Huong
 Created file
 */

/*
 Known Bugs
 
 - 27/10/2019 : William Xue
 File persistance of iOS simulator behviour is unknown, it is possible that the file name persists but the file is empty
 thus when we try to insert, the system crashes
 */

import Foundation
import SQLite

class UserData {
    
    var UserName: String
    var Walking: Bool?
    var ChairAccess: Bool?
    var WeightsAccess: Bool?
    var	ResistBandAccess: Bool?
    var Intensity: Bool?
    var PushNotifications: Bool?
    
    //Routines database
    var Routines: Connection!
    let RoutinesTable = Table("Routines")
    let RoutineName = Expression<String>("Name")
    //Will list the exercise names in the routine in a comma delimited string.
    //Ex: "ex1,ex2,ex3,ex4"
    let RoutineContent = Expression<String>("Content")
    
    //Exercise data database
    var UserExerciseData: Connection!
    let UserExerciseDataTable = Table("ExerciseData")
    let TrendYear = Expression<Int64>("Year")
    let TrendMonth = Expression<Int64>("Month")
    let TrendDay = Expression<Int64>("Day")
    let TrendHour = Expression<Int64>("Hour")
    let TrendExercise = Expression<String>("ExerciseName")
    
    //Step count database
    var StepCount: Connection!
    let StepCountTable = Table("StepCount")
    let StepYear = Expression<Int64>("Year")
    let StepMonth = Expression<Int64>("Month")
    let StepDay = Expression<Int64>("Day")
    let StepHour = Expression<Int64>("Hour")
    let StepsTaken = Expression<Int64>("StepsTaken")
    
    init(
        nameGiven: String,
        walkingDesired: Bool?,
        chairAvailable: Bool?,
        weightsAvailable: Bool?,
        resistBandAvailable: Bool?,
        intensityDesired: Bool?,
        pushNotificationsDesired: Bool?) {
        
        UserName = nameGiven
        Walking = walkingDesired
        ChairAccess = chairAvailable
        WeightsAccess = weightsAvailable
        ResistBandAccess = resistBandAvailable
        Intensity = intensityDesired
        PushNotifications = pushNotificationsDesired
        
        //Declare some variables we will use to search for our databases.
        var routinesDatabaseReady = false
        var exerciseDatabaseReady = false
        var stepCountDatabaseReady = false
        
        let fileExtension = "sqlite3"
        let routinesFileName = "Routines" + "." + fileExtension
        let exerciseFileName = "UserExerciseData" + "." + fileExtension
        let stepFileName = "StepCount" + "." + fileExtension
        
        var routinesURL: URL?
        var exerciseURL: URL?
        var stepURL: URL?
        
        //Start a FileManager object.
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            
            //Get all the files in the Documents directory.
            let documentFiles = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            //Look at each file to see if it is a file we want.
            for file in documentFiles {
                var fileName = file.lastPathComponent
                
                //We need to look for the existance of the file, along with having contents.
                if fileName == routinesFileName {
                    
                    do {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.path)
                        var fileSize = fileAttributes[FileAttributeKey.size] as! UInt64
                        let dict = fileAttributes as NSDictionary
                        fileSize = dict.fileSize()
                        
                        if fileSize != 0 {
                            routinesDatabaseReady = true
                        }
                    } catch {
                        print("Error checking Routines.sqlite3")
                    }
                    
                    routinesURL = file.absoluteURL
                    
                } else if fileName == exerciseFileName {
                    
                    do {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.path)
                        var fileSize = fileAttributes[FileAttributeKey.size] as! UInt64
                        let dict = fileAttributes as NSDictionary
                        fileSize = dict.fileSize()
                        
                        if fileSize != 0 {
                            exerciseDatabaseReady = true
                        }
                    } catch {
                        print("Error checking UserExerciseData.sqlite3")
                    }
                    
                    exerciseURL = file.absoluteURL
                    
                } else if fileName == stepFileName {
                    
                    do {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.path)
                        var fileSize = fileAttributes[FileAttributeKey.size] as! UInt64
                        let dict = fileAttributes as NSDictionary
                        fileSize = dict.fileSize()
                        
                        if fileSize != 0 {
                            stepCountDatabaseReady = true
                        }
                    } catch {
                        print("Error checking StepCount.sqlite3")
                    }
                    
                    stepURL = file.absoluteURL
                    
                }
                
            }
        } catch {
            print("Error searching Documents Directory")
        }
        
        //Connect to each database.
        do {
            let database = try Connection((routinesURL!).path)
            self.Routines = database
            
            //Create the table if the file did not exist or was empty.
            if !routinesDatabaseReady {
                let createTable = RoutinesTable.create{ (table) in
                    table.column(RoutineName, primaryKey: true)
                    table.column(RoutineContent)
                }
                
                do {
                    try self.Routines.run(createTable)
                } catch {
                    print("Error creating Routines table")
                }
            }
        } catch {
            print("Error connecting to Routines database")
        }
        
        do {
            let database = try Connection((exerciseURL!).path)
            self.UserExerciseData = database
            
            //Create the table if the file did not exist or was empty.
            if !exerciseDatabaseReady {
                let createTable = UserExerciseDataTable.create{ (table) in
                    table.column(TrendYear)
                    table.column(TrendMonth)
                    table.column(TrendDay)
                    table.column(TrendHour)
                    table.column(TrendExercise)
                }
                
                do {
                    try self.UserExerciseData.run(createTable)
                } catch {
                    print("Error creating UserExerciseData table")
                }
            }
        } catch {
            print("Error connecting to UserExerciseData database")
        }
        
        do {
            let database = try Connection((stepURL!).path)
            self.StepCount = database
            
            //Create the table if the file did not exist or was empty.
            if !stepCountDatabaseReady {
                let createTable = StepCountTable.create{ (table) in
                    table.column(StepYear)
                    table.column(StepMonth)
                    table.column(StepDay)
                    table.column(StepHour)
                    table.column(StepsTaken)
                }
                
                do {
                    try self.StepCount.run(createTable)
                } catch {
                    print("Error creating StepCount table")
                }
                
            }
        } catch {
            print("Error connecting to StepCount database")
        }
        
    }
}
