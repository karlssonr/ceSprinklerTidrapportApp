//
//  TimeRegisterTableViewController.swift
//  ceSprinklerTidrapportApp
//
//  Created by robin karlsson on 2020-01-23.
//  Copyright © 2020 robin karlsson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class TimeRegisterViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var checkBoxEgetBoende: UIButton!
    @IBOutlet weak var checkBoxNattTrakt: UIButton!
    @IBOutlet weak var checkBoxDagTrakt: UIButton!
    @IBOutlet weak var hoursTimeRegisterTextField: UITextField!
    @IBOutlet weak var hoursTeamLeaderTextField: UITextField!
    @IBOutlet weak var hoursLopandeTextField: UITextField!
    @IBOutlet weak var arbetsplatsTextField: UITextField!
    @IBOutlet weak var projektNrTextField: UITextField!
    
    
    let pickerHourTeamLeaderPickerView = UIPickerView()
    let pickerHourLopandePickerView = UIPickerView()
    let pickerHourPickerView = UIPickerView()
    let howManyhoursTimeRegistration = (1...24).map {$0}
    
    var timeReportSummary : TimeReportInfo?
    var datesFromTimeRegisterSummaryVC : Date?
   
    var db : Firestore!
    
//    var answerDagTrakt : String?
//    var answerNattTrakt : String?
//    var answerEgetBoendeTrakt : String?

    
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        let query = db.collection("TimeReportInfos").whereField("dates", isEqualTo: datesFromTimeRegisterSummaryVC)
        
        query.getDocuments() {
            (snapshot , error) in
            
            guard let documents = snapshot?.documents else {return}
            
            if documents.count > 0 {
                let document = documents[0]
                let result = Result {
                    try document.data(as: TimeReportInfo.self)
                }
                
                switch result {
                case .success(let info) :
                    if let info = info {
                        self.arbetsplatsTextField.text = info.arbetsPlats
                        self.projektNrTextField.text = info.projektNummer
                        self.hoursTimeRegisterTextField.text = info.timmar
                        self.hoursTeamLeaderTextField.text = info.timmarLagbas
                        self.hoursLopandeTextField.text = info.timmarLopande
                        self.checkBoxDagTrakt.isEnabled = info.dagTrakt
                        self.checkBoxNattTrakt.isEnabled = info.nattTrakt
                        self.checkBoxEgetBoende.isEnabled = info.egetBoende
                        
                        print(info.dagTrakt)
                        
                    }
                case .failure(let error) :
                    print("")
                }
                
                
            }
        }
        
        pickerHourPickerView.tag = 1
        pickerHourTeamLeaderPickerView.tag = 2
        pickerHourLopandePickerView.tag = 3
        
        
        
        pickerHourPickerView.delegate = self
        pickerHourPickerView.dataSource = self
        hoursTimeRegisterTextField?.inputView = pickerHourPickerView
        
        pickerHourTeamLeaderPickerView.delegate = self
        pickerHourTeamLeaderPickerView.dataSource = self
        hoursTeamLeaderTextField?.inputView = pickerHourTeamLeaderPickerView
        
        pickerHourLopandePickerView.delegate = self
        pickerHourLopandePickerView.dataSource = self
        hoursLopandeTextField?.inputView = pickerHourLopandePickerView
        
        checkBoxDagTrakt.setImage(UIImage(named: "icons8-unchecked-checkbox-100"), for: .normal)
        checkBoxEgetBoende.setImage(UIImage(named: "icons8-unchecked-checkbox-100"), for: .normal)
        checkBoxNattTrakt.setImage(UIImage(named: "icons8-unchecked-checkbox-100"), for: .normal)
        
        
        
//        checkBoxDagTrakt?.layer.cornerRadius = 5
//        checkBoxDagTrakt?.layer.borderColor = UIColor.blue.cgColor
//        checkBoxDagTrakt?.layer.borderWidth = 2

        print(datesFromTimeRegisterSummaryVC )
         let formater = DateFormatter()
        formater.dateFormat = "d LLL"
        print(formater.string(from: datesFromTimeRegisterSummaryVC!))
        
        }
    
    @IBAction func saveInfoButton(_ sender: UIButton) {
     saveTimeReportInfo()
     //print(datesFromTimeRegisterSummaryVC)
    //print(timeReportSummary)
    }
    
    
    @IBAction func checkBoxDagTraktAction1(_ sender: UIButton) {
        if sender.isSelected == false {
            checkBoxDagTrakt.setImage(UIImage(named: "icons8-checked-checkbox-100"), for: .normal)
            sender.isSelected = true

        
        }
        else {
                checkBoxDagTrakt.setImage(UIImage(named: "icons8-unchecked-checkbox-100"), for: .normal)
                    sender.isSelected = false

                
        }
    
    }
    
    @IBAction func checkBoxEgetBoendeAction(_ sender: UIButton) {
        if sender.isSelected == false {
            checkBoxEgetBoende.setImage(UIImage(named: "icons8-checked-checkbox-100"), for: .normal)
            sender.isSelected = true
        
        }
        else {
                checkBoxEgetBoende.setImage(UIImage(named: "icons8-unchecked-checkbox-100"), for: .normal)
                    sender.isSelected = false

                
        }
    }
    @IBAction func checkBoxNattTraktAction(_ sender: UIButton) {
        if sender.isSelected == false {
            checkBoxNattTrakt.setImage(UIImage(named: "icons8-checked-checkbox-100"), for: .normal)
            sender.isSelected = true

            
        
        }
        else {
                checkBoxNattTrakt.setImage(UIImage(named: "icons8-unchecked-checkbox-100"), for: .normal)
                    sender.isSelected = false
//            answerNattTrakt = " "
                
        }
    }
    

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return howManyhoursTimeRegistration.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return  String(howManyhoursTimeRegistration[row])
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.tag == 1 {
            hoursTimeRegisterTextField.text = String(howManyhoursTimeRegistration[row])
            self.view.endEditing(false)
        }
        if pickerView.tag == 2 {
            hoursTeamLeaderTextField.text = String(howManyhoursTimeRegistration[row])
            self.view.endEditing(false)
        }
        if pickerView.tag == 3 {
            hoursLopandeTextField.text = String(howManyhoursTimeRegistration[row])
            self.view.endEditing(false)
        }
    }
    
    func saveTimeReportInfo() {
        let arbetsPlats = arbetsplatsTextField.text
        let projektNummer = projektNrTextField.text
        let timmar = hoursTimeRegisterTextField.text
        let timmarLagbas = hoursTeamLeaderTextField.text
        let timmarLopande = hoursLopandeTextField.text
        let dagTrakt = checkBoxDagTrakt.isSelected
        let nattTrakt = checkBoxNattTrakt.isSelected
        let egetBoende = checkBoxEgetBoende.isSelected
        guard let dates = datesFromTimeRegisterSummaryVC else {return}

        
        timeReportSummary = TimeReportInfo(arbetsPlats: arbetsPlats, projektNummer: projektNummer, timmar: timmar, timmarLagbas: timmarLagbas, timmarLopande: timmarLopande, dagTrakt: dagTrakt, nattTrakt: nattTrakt, egetBoende: egetBoende, dates: dates)
        
        
        do {
            try db.collection("TimeReportInfos").addDocument(from: timeReportSummary)
        } catch {}
        
      //  print("saved report \(timeReportSummary)")
    }

    // MARK: - Table view data source



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
