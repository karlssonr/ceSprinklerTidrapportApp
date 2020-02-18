//
//  ViewController.swift
//  ceSprinklerTidrapportApp
//
//  Created by robin karlsson on 2020-01-17.
//  Copyright © 2020 robin karlsson. All rights reserved.
//

import UIKit
import Firebase

class TimeRegisterSummaryViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var mondayFromWeek: UILabel!
    @IBOutlet weak var thuesdayFromWeek: UILabel!
    @IBOutlet weak var wednesdayFromWeek: UILabel!
    @IBOutlet weak var thursdayFromWeek: UILabel!
    @IBOutlet weak var fridayFromWeek: UILabel!
    @IBOutlet weak var saturdayFromWeek: UILabel!
    @IBOutlet weak var sundayFromWeek: UILabel!
    @IBOutlet weak var dateViewTidRapp: UIView!
    @IBOutlet weak var chooseWeekTextField: UITextField!
    
    
    @IBOutlet weak var arbetsplatsMonday: UILabel!
    @IBOutlet weak var arbetsplatsThuesday: UILabel!
    @IBOutlet weak var arbetsplatsWednesday: UILabel!
    @IBOutlet weak var arbetsplatsThursday: UILabel!
    @IBOutlet weak var arbetsplatsFriday: UILabel!
    @IBOutlet weak var arbetsplatsSaturday: UILabel!
    @IBOutlet weak var arbetsplatsSunday: UILabel!
    
 
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
    
    var wholeWeekInfo : [String]?
    
    var infoMonday : String?
    var infoThuesday : String?
    var infoWednesday : String?
    var infoThursday : String?
    var infoFriday : String?
    var infoSaturday : String?
    var infoSunday : String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        db = Firestore.firestore()
        

        
        
        

        
        
        // om vi lyckas läsa in något i weeksaved -> ska köra metoden updateDatesfrom....
 
        picker.delegate = self
        picker.dataSource = self
        
        chooseWeekTextField?.inputView = picker
        
        

        
    }
    
    @IBAction func skickaButtonPressed(_ sender: UIButton) {
  
        sendAndSaveTimereport()
        
        print(infoMonday)
        
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        
        let weekSaved = defaults.integer(forKey: weekKey)
        if weekSaved != 0 {
            
            updateDatesFrom(weekNumber: weekSaved)
            chooseWeekTextField.text = String(weekSaved)
//            arbetsplatsMonday.text =
//            setArbetsplatsFromDatesThroughFireBase()
            
        }
            
    }
    
 
    


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
  
    
    func updateDatesFrom(weekNumber: Int) {
        dates = []
        arbetsplatsMonday.text = ""
        arbetsplatsThuesday.text = ""
        arbetsplatsWednesday.text = ""
        arbetsplatsThursday.text = ""
        arbetsplatsFriday.text = ""
        arbetsplatsSaturday.text = ""
        arbetsplatsSunday.text = ""
        
        timmarMonday.text = "0"
        timmarThuesday.text = "0"
        timmarWednesday.text = "0"
        timmarThursday.text = "0"
        timmarFriday.text = "0"
        timmarSaturday.text = "0"
        timmarSunday.text = "0"
        
        let todaysDate = Date()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: todaysDate)

        
        let components = DateComponents(weekOfYear: weekNumber, yearForWeekOfYear: year)
        guard let date = Calendar.current.date(from: components) else {return }
        
        let formater = DateFormatter()
        formater.dateFormat = "d LLL"
       // print(formater.string(from: date) )
        
        if let monday = calendar.date(byAdding: .day, value: 1, to: date) {
            dates.append(monday)
        
            let mon = formater.string(from: monday)
            mondayFromWeek.text = mon
        }
        if let thuesday = calendar.date(byAdding: .day, value: 2, to: date) {
             dates.append(thuesday)
            let thu = formater.string(from: thuesday)
            thuesdayFromWeek.text = thu
            
        }
        if let wednesday = calendar.date(byAdding: .day, value: 3, to: date) {
            dates.append(wednesday)
            let wed = formater.string(from: wednesday)
            wednesdayFromWeek.text = wed
            
        }
        if let thursday = calendar.date(byAdding: .day, value: 4, to: date) {
            dates.append(thursday)
            let thur = formater.string(from: thursday)
            thursdayFromWeek.text = thur
            
        }
        if let friday = calendar.date(byAdding: .day, value: 5, to: date) {
            dates.append(friday)
            let fri = formater.string(from: friday)
            fridayFromWeek.text = fri
        }
        if let saturday = calendar.date(byAdding: .day, value: 6, to: date) {
            dates.append(saturday)
            let sat = formater.string(from: saturday)
            saturdayFromWeek.text = sat
        }
        if let sunday = calendar.date(byAdding: .day, value: 7, to: date) {
            dates.append(sunday)
            let sun = formater.string(from: sunday)
            sundayFromWeek.text = sun
        }
        
        setArbetsplatsFromDatesThroughFireBase()
        setTimmarFromDatesThroughFireBase()
        
        
    }
    
    func saveSelectedRow(row: Int) {
        let defaults = UserDefaults.standard
        defaults.set(row, forKey: userDefaultsRowKey)
        defaults.synchronize()
    }
    
    func setArbetsplatsFromDatesThroughFireBase() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let queryMonday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[0])
        
        let queryThuesday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[1])
        
        let queryWednesday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[2])
        
        let queryThursday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[3])
        
        let queryFriday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[4])
        
        let querySaturday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[5])
        
        let querySunday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[6])
        
        queryMonday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsMonday.text = info.arbetsPlats
                     
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryThuesday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsThuesday.text = info.arbetsPlats
                        
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryWednesday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsWednesday.text = info.arbetsPlats
                   
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryThursday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsThursday.text = info.arbetsPlats
                      
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryFriday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsFriday.text = info.arbetsPlats
            
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        querySaturday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsSaturday.text = info.arbetsPlats
                
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        querySunday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.arbetsplatsSunday.text = info.arbetsPlats
        
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
    }
    
    func setTimmarFromDatesThroughFireBase()
    {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let queryMonday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[0])
        
        let queryThuesday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[1])
        
        let queryWednesday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[2])
        
        let queryThursday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[3])
        
        let queryFriday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[4])
        
        let querySaturday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[5])
        
        let querySunday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[6])
        
        queryMonday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.timmarMonday.text = info.timmar
                     
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryThuesday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.timmarThuesday.text = info.timmar
                        
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryWednesday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.timmarWednesday.text = info.timmar
                   
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryThursday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.timmarThursday.text = info.timmar
                      
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryFriday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                       self.timmarFriday.text = info.timmar
            
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        querySaturday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                       self.timmarSaturday.text = info.timmar
                
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        querySunday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.timmarSunday.text = info.timmar
        
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
    }
    
    func sendAndSaveTimereport() {
        
//        self.infoMonday = ""
//        self.infoThuesday = ""
//        self.infoWednesday = ""
//        self.infoThuesday = ""
//        self.infoFriday = ""
//        self.infoSaturday = ""
//        self.infoSunday = ""
//        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let queryMonday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[0])
        
        let queryThuesday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[1])
        
        let queryWednesday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[2])
        
        let queryThursday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[3])
        
        let queryFriday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[4])
        
        let querySaturday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[5])
        
        let querySunday = db.collection("users").document(currentUserId).collection("TimeReportInfos").whereField("dates", isEqualTo: dates[6])
        
        
        queryMonday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.infoMonday = info.toString()
                     
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryThuesday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.infoThursday = info.toString()
                        
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryWednesday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.infoWednesday = info.toString()
                   
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryThursday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.infoThursday = info.toString()
                      
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        queryFriday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                       self.infoFriday = info.toString()
            
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        querySaturday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                       self.infoSaturday = info.toString()
                
                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }
        
        querySunday.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else { return }
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info):
                    if let info = info {
                        self.infoSunday = info.toString()

                    }
                case .failure(let error) :
                    print("error")
                }
            }
        }

//        self.wholeWeekInfo += infoMonday
    }
    
}

