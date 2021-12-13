//
//  SceneDelegate.swift
//  reservation
//
//  Created by Mahdi Sabbouri
//

import UIKit
import SQLite3

class AddNewReservationViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var noOfGuestsTextField: UITextField!
    
    var delegate: ViewController!
    
    @IBAction func confirmPressed(_ sender: Any) {
        var db: OpaquePointer?
        
        // database file address
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ReservationDatabase.sqlite")
        
        // opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let seats = noOfGuestsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Reservations (dummyName, firstName, lastName, seats) VALUES (?, ?,?,?)"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        // binding statement 1
        sqlite3_bind_text(stmt, 1, firstName, -1, nil)
        
        // binding statement 2
        sqlite3_bind_text(stmt, 2, firstName!+" "+lastName! , -1, nil)
        
        // binding user input for number of guests
        sqlite3_bind_int(stmt, 3, (seats! as NSString).intValue)
        
        sqlite3_step(stmt)
        
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        noOfGuestsTextField.text = ""
        
        sqlite3_finalize(stmt)
        
        delegate?.readValues()
        
        self.dismiss(animated: true, completion: nil)
    }


}

