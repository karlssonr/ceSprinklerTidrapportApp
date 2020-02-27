//
//  TimeReportInfo.swift
//  ceSprinklerTidrapportApp
//
//  Created by robin karlsson on 2020-01-29.
//  Copyright © 2020 robin karlsson. All rights reserved.
//

import Foundation
import Firebase


class TimeReportInfo : Codable {
    let arbetsPlats : String
    let projektNummer : String
    let timmar : String
    let timmarLagbas : String
    let timmarLopande : String
    let dagTrakt : Bool
    let nattTrakt : Bool
    let egetBoende : Bool
    let dates : Date
    
    init(arbetsPlats: String?, projektNummer: String?, timmar: String?, timmarLagbas: String?, timmarLopande: String?, dagTrakt: Bool, nattTrakt: Bool, egetBoende: Bool, dates: Date) {
        if let plats = arbetsPlats {
            self.arbetsPlats = plats
        } else {
            self.arbetsPlats = ""
        }
        
        if let projektnr = projektNummer {
            self.projektNummer = projektnr
        } else {
            self.projektNummer = ""
        }
        
        if let tim = timmar {
            self.timmar = tim
        } else {
            self.timmar = ""
        }
        
        if let timLagbas = timmarLagbas {
            self.timmarLagbas = timLagbas
        } else {
            self.timmarLagbas = ""
        }
        
        if let timLopande = timmarLopande {
            self.timmarLopande = timLopande
        } else {
            self.timmarLopande = ""
        }
        
        self.dagTrakt = dagTrakt
        self.nattTrakt = nattTrakt
        
        self.egetBoende = egetBoende

        self.dates = dates
        
    }
    
    func toString() -> String {
        var str = ""
        
        let formater = DateFormatter()
        formater.dateFormat = "d LLL"
        
        let date = formater.string(from: dates)
        
       // formater.dateFormat = "dag"
        //let weekday = formater.string(from: dates)
        
       // str += weekday
        
        str += date
        
        str += arbetsPlats + "," + projektNummer + "," + timmar + "," + timmarLagbas + "," + timmarLopande
        
        if dagTrakt == false {
            str += "" + ","
        } else {
            str += "X" + ","
        }
        
        if nattTrakt == false {
            str += "" + ","
        } else {
            str += "X" + ","
        }
        
        if egetBoende == false {
            str += "" + ","
        } else {
            str += "X" + ","
        }
        
        return str
    }
    
    
    
}

