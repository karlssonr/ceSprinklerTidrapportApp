//
//  ViewController.swift
//  ceSprinklerTidrapportApp
//
//  Created by robin karlsson on 2020-01-17.
//  Copyright © 2020 robin karlsson. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class TimeRegisterSummaryViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    
    //Labels for dates
    @IBOutlet weak var mondayFromWeek: UILabel!
    @IBOutlet weak var thuesdayFromWeek: UILabel!
    @IBOutlet weak var wednesdayFromWeek: UILabel!
    @IBOutlet weak var thursdayFromWeek: UILabel!
    @IBOutlet weak var fridayFromWeek: UILabel!
    @IBOutlet weak var saturdayFromWeek: UILabel!
    @IBOutlet weak var sundayFromWeek: UILabel!
    @IBOutlet weak var dateViewTidRapp: UIView!
    @IBOutlet weak var chooseWeekTextField: UITextField!
    
    //labels for "arbetsplats"
    @IBOutlet weak var arbetsplatsMonday: UILabel!
    @IBOutlet weak var arbetsplatsThuesday: UILabel!
    @IBOutlet weak var arbetsplatsWednesday: UILabel!
    @IBOutlet weak var arbetsplatsThursday: UILabel!
    @IBOutlet weak var arbetsplatsFriday: UILabel!
    @IBOutlet weak var arbetsplatsSaturday: UILabel!
    @IBOutlet weak var arbetsplatsSunday: UILabel!
    
    //labels for "timmar"
    @IBOutlet weak var timmarMonday: UILabel!
    @IBOutlet weak var timmarThuesday: UILabel!
    @IBOutlet weak var timmarWednesday: UILabel!
    @IBOutlet weak var timmarThursday: UILabel!
    @IBOutlet weak var timmarFriday: UILabel!
    @IBOutlet weak var timmarSaturday: UILabel!
    @IBOutlet weak var timmarSunday: UILabel!
    
    
    // content for picker view
    let chooseWeekArray = ["1","2","3","4","5","6","7","8","9","10",
                           "11","12","13","14","15","16","17","18","19","20",
                           "21","22","23","24","25","26","27","28","29","30",
                           "31","32","33","34","35","36","37","38","39","40",
                           "41","42","43","44","45","46","47","48","49","50",
                           "51","52"]
    
    var picker = UIPickerView()
    
    var dates : [Date] = []
    
    var mondaySegueID = "segueFromMonday"
    var thuesdaySegueID = "segueFromThuesday"
    var wednesdaySegueID = "segueFromWednesday"
    var thursdaySegueID = "segueFromThursday"
    var fridaySegueID = "segueFromFriday"
    var saturdaySegueID = "segueFromSaturday"
    var sundaySegueID = "segueFromSunday"
    
    let weekKey = "weekNumber"
    let defaults = UserDefaults.standard
    let userDefaultsRowKey = "defaultPickerRow"
    
    var db : Firestore!
    
    var wholeWeekInfo = [TimeReportInfo]()
    
    var infoMonday : String?
    var infoThuesday : String?
    var infoWednesday : String?
    var infoThursday : String?
    var infoFriday : String?
    var infoSaturday : String?
    var infoSunday : String?
    
    var filename : URL?
    var week : String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        db = Firestore.firestore()
        
        picker.delegate = self
        picker.dataSource = self
        
        chooseWeekTextField?.inputView = picker
        
        title = "Ny Tidrapport"
        
    }
    
    @IBAction func skickaButtonPressed(_ sender: UIButton) {
        
        createTextFile()
        sendEmail()
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //loading last viewed week
        let weekSaved = defaults.integer(forKey: weekKey)
        if weekSaved != 0 {
            
            updateDatesFrom(weekNumber: weekSaved)
            chooseWeekTextField.text = String(weekSaved)
        }
        
    }
    
    
    
    
    //seding date from "TimeRegisterSummaryViewController" to "TimeRegisterViewController"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let timeRegisterVC = segue.destination as? TimeRegisterViewController else {return}
        if segue.identifier == mondaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[0]
        }
        if segue.identifier == thuesdaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[1]
        }
        if segue.identifier == wednesdaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[2]
        }
        if segue.identifier == thursdaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[3]
        }
        if segue.identifier == fridaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[4]
        }
        if segue.identifier == saturdaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[5]
        }
        if segue.identifier == sundaySegueID {
            timeRegisterVC.datesFromTimeRegisterSummaryVC = dates[6]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chooseWeekArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chooseWeekArray[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chooseWeekTextField.text = chooseWeekArray[row]
        guard let weekNumber = Int(chooseWeekArray[row]) else {return}
        updateDatesFrom(weekNumber: weekNumber)
        
        // spara weeknumber i user defaults
        defaults.set(weekNumber, forKey: weekKey)
        
        self.view.endEditing(false)
        saveSelectedRow(row: row)
    }
    
    //set up dates from week choosen
    func updateDatesFrom(weekNumber: Int) {
        dates = []
        arbetsplatsMonday.text = ""
        arbetsplatsThuesday.text = ""
        arbetsplatsWednesday.text = ""
        arbetsplatsThursday.text = ""
        arbetsplatsFriday.text = ""
        arbetsplatsSaturday.text = ""
        arbetsplatsSunday.text = ""
        
        timmarMonday.text = ""
        timmarThuesday.text = ""
        timmarWednesday.text = ""
        timmarThursday.text = ""
        timmarFriday.text = ""
        timmarSaturday.text = ""
        timmarSunday.text = ""
        
        let todaysDate = Date()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: todaysDate)
        
        
        let components = DateComponents(weekOfYear: weekNumber, yearForWeekOfYear: year)
        guard let date = Calendar.current.date(from: components) else {return }
        
        let formater = DateFormatter()
        formater.dateFormat = "d LLL"
        
        
        if let monday = calendar.date(byAdding: .day, value: 0, to: date) {
            dates.append(monday)
            
            let mon = formater.string(from: monday)
            mondayFromWeek.text = mon
        }
        if let thuesday = calendar.date(byAdding: .day, value: 1, to: date) {
            dates.append(thuesday)
            let thu = formater.string(from: thuesday)
            thuesdayFromWeek.text = thu
            
        }
        if let wednesday = calendar.date(byAdding: .day, value: 2, to: date) {
            dates.append(wednesday)
            let wed = formater.string(from: wednesday)
            wednesdayFromWeek.text = wed
            
        }
        if let thursday = calendar.date(byAdding: .day, value: 3, to: date) {
            dates.append(thursday)
            let thur = formater.string(from: thursday)
            thursdayFromWeek.text = thur
            
        }
        if let friday = calendar.date(byAdding: .day, value: 4, to: date) {
            dates.append(friday)
            let fri = formater.string(from: friday)
            fridayFromWeek.text = fri
        }
        if let saturday = calendar.date(byAdding: .day, value: 5, to: date) {
            dates.append(saturday)
            let sat = formater.string(from: saturday)
            saturdayFromWeek.text = sat
        }
        if let sunday = calendar.date(byAdding: .day, value: 6, to: date) {
            dates.append(sunday)
            let sun = formater.string(from: sunday)
            sundayFromWeek.text = sun
        }
        
        setUpDataArbetsplatsAndTimmar()
        
    }
    
    
    func saveSelectedRow(row: Int) {
        let defaults = UserDefaults.standard
        defaults.set(row, forKey: userDefaultsRowKey)
        defaults.synchronize()
    }
    
    //getting data from firebase and setting up data in to "Arbetsplats" and "Timmar" labels, and saving data into wholeWeekInfo array
    func setUpDataArbetsplatsAndTimmar() {
        
        wholeWeekInfo = []
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let query = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isGreaterThanOrEqualTo:  dates[0]).limit(to: 7)
        
        
        query.getDocuments() {
            (snapshot , error) in
            
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        if info.dates <= self.dates[6] {
                            
                            self.wholeWeekInfo.append(info)
                            if info.dates == self.dates[0] {
                                self.timmarMonday.text = info.timmar
                                self.arbetsplatsMonday.text = info.arbetsPlats
                            }
                            
                            if info.dates == self.dates[1] {
                                self.timmarThuesday.text = info.timmar
                                self.arbetsplatsThuesday.text = info.arbetsPlats
                            }
                            
                            if info.dates == self.dates[2] {
                                self.timmarWednesday.text = info.timmar
                                self.arbetsplatsWednesday.text = info.arbetsPlats
                            }
                            
                            if info.dates == self.dates[3] {
                                self.timmarThursday.text = info.timmar
                                self.arbetsplatsThursday.text = info.arbetsPlats
                            }
                            
                            if info.dates == self.dates[4] {
                                self.timmarFriday.text = info.timmar
                                self.arbetsplatsFriday.text = info.arbetsPlats
                            }
                            
                            if info.dates == self.dates[5] {
                                self.timmarSaturday.text = info.timmar
                                self.arbetsplatsSaturday.text = info.arbetsPlats
                            }
                            
                            if info.dates == self.dates[6] {
                                self.timmarSunday.text = info.timmar
                                self.arbetsplatsSunday.text = info.arbetsPlats
                            }
                            
                        }
                        
                    }
                case .failure(let error) :
                    print(error)
                }
            }
            
        }
        
    }
    
    
    func createTextFile () {
        
        self.week = ""
        
        guard let currentWeek = chooseWeekTextField?.text else {return}
        
        filename =  getDocumentsDirectory().appendingPathComponent("vecka" + currentWeek + ".cvs")
        
        
        guard let filename = filename else {return}
        
        self.week += "Namn: Robin Karlsson" + "\n"
        self.week += "Anställnings Nummer: 215" + "\n"
        self.week += "Datum," + "Dag," + "Arbetsplats," + "Projekt Nr," + "Tim," + "Tim Lagbas," + "Tim Löpande," + "Dagtrakt," + "Nattrakt," + "Eget Boende," + "\n"
        for day in wholeWeekInfo {
            
            week +=  day.toString() + "\n"
            
        }
        
        
        do {
            try week.write(to: filename, atomically: true, encoding: .utf8)
        } catch {
            print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func sendEmail() {
        
        guard let currentWeek = chooseWeekTextField?.text else {return}
        guard let filename = filename else {return}
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["karlssonr1989@gmail.com"])
            mail.setSubject("Tidrapport vecka: " + currentWeek)
            mail.setMessageBody("Tidrapport för vecka: " + currentWeek, isHTML: true)
            do {
                let fileData = try Data(contentsOf: filename)
                mail.addAttachmentData(fileData, mimeType: "text/txt", fileName: "vecka" + currentWeek + ".csv")
            } catch {
                print("fildata error")
            }
            
            
            present(mail, animated: true)
            print("email sent")
        } else {
            print("no email sent")
        }
    }
    
}
