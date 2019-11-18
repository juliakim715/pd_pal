//
//  TrendViewController.swift
//  PD_PAL
//
//  Created by Zhong Jia Xue on 2019-10-18.
//  Copyright © 2019 WareOne. All rights reserved.
//
// Revision History:
// <Date, Name, Changes made>
// <October 27, 2019, Spencer Lall, applied default page design>
// <November 2, 2019, William Xue , Added table displaying exercise history and step count>
// <November 8, 2019, Julia Kim, Getting counts for each category>
// <November 11, 2019, Julia Kim, Adding scrolling to the page, generate radar graph, implemented date pickers>
// <November 13, 2019, Julia Kim, Added hours to the date picker, input validation for date picker range, updating radar graph utilizing the same update button for the table>
// <November 14, 2019, Julia Kim, Refactored date querying to exercises completed database, fixed update button for radar>
// <November 15, 2019, Julia Kim, Added Line Chart for step data, fixed scrollable view, refactored date input validation>
// <November 18, 2019, Julia Kim, Fixed date querying input validation and radar chart>

/*
 Known Bugs
 November 11, 2019: Julia Kim
 -The graph generated does not update after loading initially as that feature has not been fully implemented yet. -> fixed with an update button Nov 13, 2019
 -Date Picker not integrated yet. -> done Nov 13, 2019
 November 14, 2019: Julia Kim
 -Comparing dates component wise will not handle edge cases -> Fixed to compare dates properly Nov 14, 2019
 November 18, 2019: Julia Kim
 -Having the default end date will introduce a bug with the input validation -> commented out this part since this was something extra
 */

import UIKit
import RadarChart //import to allow creating radar graph
import Charts //import to allow bar or line chart

class TrendViewController: UIViewController, UITableViewDataSource{

    // IBOutlet labels
    @IBOutlet weak var Title_label: UILabel!
    @IBOutlet weak var trendTableView: UITableView!
    @IBOutlet weak var UpdateButton: UIButton!
    
    @IBOutlet weak var ClearDates: UIButton!
    
    @IBOutlet weak var rChartView: RadarChart.RadarChartView! //to avoid namespace clash
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    
    private var sDatePicker: UIDatePicker?
    private var eDatePicker: UIDatePicker?
    private var sdateSelected = false
    private var edateSelected = false
    
    let dateFormatter = DateFormatter()
    
    private var eDateYear = 0
    private var eDateMonth = 0
    private var eDateDay = 0
    private var eDateHour = 0
    private var eDateMinute = 0
    
    private var sDateYear = 0
    private var sDateMonth = 0
    private var sDateDay = 0
    private var sDateHour = 0
    private var sDateMinute = 0
    
    private var strengthCounter = 0
    private var flexCounter = 0
    private var cardioCounter = 0
    private var balanceCounter = 0
    
    var exerciseData = global_UserData.Get_Exercises_all()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Global.color_schemes.m_bgColor // background color

        getDatePicker()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TrendViewController.viewTapped(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapGesture)
        
        //to get the scroll working
        //stackoverflow.com/questions/28144739/swift-uiscrollview-not-scrolling
        scroller?.isScrollEnabled = true
        scroller?.contentSize = CGSize(width: 375, height: 3200) //content size must be greater than scroll view constraint
        self.view.addSubview(scroller)
        
        //view.backgroundColor = Setup.m_bgColor  // background color
        trendTableView.dataSource = self
        
        let userData = global_UserData.Get_User_Data()
        let username = userData.UserName
                
        // message
        self.show_page_message(s1: username + " Trends!", s2: "Trends")
        self.generateRadarChart()
        self.prepareStepData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = Global.color_schemes.m_blue3     // nav bar color
        self.generateRadarChart() //load blank radar chart on load
        self.prepareStepData() //load blank line chart on load
       
    }
    
    override func viewDidLayoutSubviews() {
        //this is for graph subviews
        super.viewDidLayoutSubviews()
        rChartView?.prepareForDrawChart()
        rChartView?.setNeedsLayout()
        rChartView?.setNeedsDisplay()   
    }
  
    // table View Material From https://www.youtube.com/watch?v=kCIQM7L-w4Y
    func numberOfSections(in tableView: UITableView) -> Int {
        //one section for exercise history and one section for step count
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return exerciseData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!

        //so that the first row is step count and the other rows are from exerciseData
        let row = indexPath.row - 1
        
        if(row == -1) {
            let text =  "Step Count This Hour: " + global_StepTracker.steps.description
            cell.textLabel?.text = text
        }

        else {
            let text = "\(exerciseData[row].Year)/\(exerciseData[row].Month)/" +
            "\(exerciseData[row].Day) Hour: \(exerciseData[row].Hour)       \(exerciseData[row].nameOfExercise)"
            cell.textLabel?.text = text
        }
        return cell
    }

    @IBAction func Update(_ sender: UIButton) {
        exerciseData = global_UserData.Get_Exercises_all()
        self.trendTableView.reloadData()
        self.generateRadarChart()
        self.viewDidLayoutSubviews()
        self.prepareStepData() //this will call generateStepChart
       
    }

    @IBAction func clearDates(_ sender: UIButton){
        //clear date picker fields
        startDate.text = nil
        endDate.text = nil
        startDate.placeholder = "Pick a Start Date"
        endDate.placeholder = "Pick an End Date"
        sdateSelected = false
        edateSelected = false
    }
    
    func getDatePicker(){
        //let user select the date for step counter
        sDatePicker = UIDatePicker()
        eDatePicker = UIDatePicker()
        sDatePicker?.datePickerMode = .dateAndTime
        sDatePicker?.addTarget(self, action: #selector(TrendViewController.sDateChanged(datePicker:)), for: .valueChanged)
        startDate.inputView = sDatePicker
        
        eDatePicker?.datePickerMode = .dateAndTime
        
        /*
        //default end date
        eDatePicker?.date = Date() //default value of end date to be today's date
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        endDate.text = dateFormatter.string(from: eDatePicker!.date)
         */
        
        eDatePicker?.addTarget(self, action: #selector(TrendViewController.eDateChanged(datePicker:)), for: .valueChanged)
        endDate.inputView = eDatePicker
        
     
    }
    
    @objc func sDateChanged(datePicker: UIDatePicker){
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        startDate.text = dateFormatter.string(from: datePicker.date)
        
        sDateYear = Calendar.current.component(.year, from: datePicker.date)
        sDateMonth = Calendar.current.component(.month, from: datePicker.date)
        sDateDay = Calendar.current.component(.day, from: datePicker.date)
        sDateHour = Calendar.current.component(.hour, from: datePicker.date)
        sDateMinute = Calendar.current.component(.minute, from: datePicker.date)
        
        sdateSelected = true
        
        //input validation
        if edateSelected
        {
            let convertRaw = DateFormatter()
            convertRaw.dateFormat = "MM/dd/yyyy HH:mm"
            let sDateRaw = "\(sDateMonth)/" + "\(sDateDay)/" + "\(sDateYear) " + "\(sDateHour):" + "\(sDateMinute)"
            let eDateRaw = "\(eDateMonth)/" + "\(eDateDay)/" + "\(eDateYear) " + "\(eDateHour):" + "\(eDateMinute)"
            let converted_sDate = convertRaw.date(from: sDateRaw) as Date?
            let converted_eDate = convertRaw.date(from: eDateRaw) as Date?
            
            if converted_sDate?.compare(converted_eDate!) == .orderedAscending
            {
                //start date is smaller than end date
                self.view.endEditing(true)
            }
            else
            {
                self.clearStartDate()
            }
        }
    
    }
    
    @objc func eDateChanged(datePicker: UIDatePicker){
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        endDate.text = dateFormatter.string(from: datePicker.date)
        
        eDateYear = Calendar.current.component(.year, from: datePicker.date)
        eDateMonth = Calendar.current.component(.month, from: datePicker.date)
        eDateDay = Calendar.current.component(.day, from: datePicker.date)
        eDateHour = Calendar.current.component(.hour, from: datePicker.date)
        eDateMinute = Calendar.current.component(.minute, from: datePicker.date)
        
        edateSelected = true
        
        //input validation
        let convertRaw = DateFormatter()
        convertRaw.dateFormat = "MM/dd/yyyy HH:mm"
        let sDateRaw = "\(sDateMonth)/" + "\(sDateDay)/" + "\(sDateYear) " + "\(sDateHour):" + "\(sDateMinute)"
        let eDateRaw = "\(eDateMonth)/" + "\(eDateDay)/" + "\(eDateYear) " + "\(eDateHour):" + "\(eDateMinute)"
        let converted_sDate = convertRaw.date(from: sDateRaw) as Date?
        let converted_eDate = convertRaw.date(from: eDateRaw) as Date?
        
        if converted_sDate?.compare(converted_eDate!) == .orderedAscending
        {
            //start date is smaller than end date
            self.view.endEditing(true)
        }
        else
        {
            self.clearEndDate()
        }
   
   
    }
    
    func clearStartDate(){
        startDate.text = nil
        startDate.placeholder = "Start date must be smaller than end date"
        sdateSelected = false
        self.getDatePicker()
    }
    
    func clearEndDate(){
        endDate.text = nil
        endDate.placeholder = "End date must be greater than start date"
        edateSelected = false
        self.getDatePicker()
    }
        
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func generateRadarChart(){
        /*Using the library from github.com/nkmrh/RadarChart*/
        let color = UIColor(red:0.580, green:0.541, blue:0.867, alpha:0.50)
        let backgroundColor = UIColor(red:0.851, green:0.851, blue:0.941, alpha:1.00)
        let xAxisColor = UIColor(red:0.396, green:0.769, blue:0.914, alpha:1.00)
        let yAxisColor = UIColor(red:0.596, green:0.863, blue:0.945, alpha:1.50)
        let fontColor = UIColor(red:0.259, green:0.365, blue:0.565, alpha:1.00)
        
        rChartView?.data = self.exerciseCategoryCount() //get the user exercise data
        rChartView?.labelTexts = ["Flexibility", "Cardio", "Balance", "Strength"]
        rChartView?.numberOfVertexes = 4
        rChartView?.numberTicks = 20 //any more ticks would look very condensed. Leaving the full data for the web component
        rChartView?.style = RadarChartStyle(color: color,backgroundColor: backgroundColor, xAxis: RadarChartStyle.Axis(colors: [xAxisColor], widths: [0.5, 0.5, 0.5, 0.5, 2.0]),yAxis: RadarChartStyle.Axis(colors: [yAxisColor], widths: [0.5]), label: RadarChartStyle.Label(fontName: "Helvetica", fontColor: fontColor, fontSize: 15, lineSpacing: 0, letterSpacing: 0, margin: 10))
        rChartView?.option = RadarChartOption()
    }
    
    //This function fetches exercises done by the user, identifies the category to count how many exercises are done in each category
    func exerciseCategoryCount() -> [Int]{
        let exerciseData = global_UserData.Get_Exercises_all()
    
        var categoryMatch = (" ", " ", " ", " ", 0)
        var catCount = [0, 0, 0, 0]
        var rawDate = "00/00/0000 HH"
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        let sDateRaw = "\(sDateMonth)/" + "\(sDateDay)/" + "\(sDateYear) " + "\(sDateHour)"
        let eDateRaw = "\(eDateMonth)/" + "\(eDateDay)/" + "\(eDateYear) " + "\(eDateHour)"
        let converted_sDate = dateFormatter.date(from: sDateRaw) as Date? ?? Date()
        let converted_eDate = dateFormatter.date(from: eDateRaw) as Date? ?? Date()
        
        for entry in exerciseData{
            //get the category of the exercise done fetched from the DB for the selected date

            categoryMatch = global_ExerciseData.read_exercise(NameOfExercise: entry.nameOfExercise)
            rawDate = "\(entry.Month)/" + "\(entry.Day)/" + "\(entry.Year) " + "\(entry.Hour)"
            //print(rawDate)
            let convertedRaw = dateFormatter.date(from: rawDate) as Date? ?? Date()
            
            //figure out which counter to increment
            if sdateSelected
            {
                //if entry in DB is greater than start date and smaller than end date, fetch and add to count
	                if convertedRaw.compare(converted_sDate) == .orderedDescending && convertedRaw.compare(converted_eDate) == .orderedAscending
                {
                    if categoryMatch.1 as String == "Flexibility"
                    {
                        flexCounter += 1
                        //print(categoryMatch.1)
                        //print(flexCounter)
                        catCount[0] = flexCounter
                    }
                    else if categoryMatch.1 as String == "Cardio"
                    {
                        cardioCounter += 1
                        //print(categoryMatch.1)
                        //print(cardioCounter)
                        catCount[1] = cardioCounter
                    }
                    else if categoryMatch.1 as String == "Balance"
                    {
                        balanceCounter += 1
                        catCount[2] = balanceCounter
                    }
                    else if categoryMatch.1 as String == "Strength"
                    {
                        strengthCounter += 1
                        catCount[3] = strengthCounter
                    }
                    else
                    {
                        print("Not a valid category")
                    }
                }
            }
        }
        
        
        return catCount
    }
    
    func generateStepChart(dataPoints: [Double], values: [Double]){
        //this is for step counter
        /* www.appcoda.com/ios-charts-api-tutorial/ */
        
        var dataEntries: [ChartDataEntry] = []
        
        
        for i in 0..<dataPoints.count{
            let dataEntry = ChartDataEntry(x: dataPoints[i], y: values[i])
            dataEntries.append(dataEntry)
            
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Number of Steps")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        
    }
    
    func prepareStepData(){
        //get step data for the selected range of dates
        //limit querying step data to be within the same day for hourly data
        //any more data would just look very condensed on the mobile device.
        //leave the full dataset for the web?
        
        var stepDataHourly: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //gets hourly data for the start date selected (one day)
        let hoursOfDay: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
        
        if eDateDay == sDateDay && eDateHour != sDateHour //same day. Get hourly data
        {
            for i in 0..<(eDateHour-sDateHour) //eDateHour will always be greater than sDateHour if same year, month and day due to the input validation
            {
                stepDataHourly[i] = Double(global_UserData.Get_Steps_Taken(TargetYear: sDateYear, TargetMonth: sDateMonth, TargetDay: sDateDay, TargetHour: sDateHour+i))
                
                //print("StepHourly: \(stepDataHourly[i])")
            }
            
            generateStepChart(dataPoints: hoursOfDay, values: stepDataHourly)
            /*
             //test
             stepDataHourly = [1.0, 2.0, 3.0, 4.0, 5.0] //dummy values
             generateStepChart(dataPoints: hoursOfDay, values: stepDataHourly)*/
        }
        else
        {
            //max step data that can be queried is one day for hourly data
            stepDataHourly = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //default values
            generateStepChart(dataPoints: hoursOfDay, values: stepDataHourly)
            print("No graph for step counter is generated. To generate a step counter graph, please set the duration to be within the same day.")
        }
        
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
