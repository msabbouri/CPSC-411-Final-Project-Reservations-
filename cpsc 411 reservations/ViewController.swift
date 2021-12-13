//
//  SceneDelegate.swift
//  reservation
//
//  Created by Mahdi Sabbouri
//


import UIKit
import SQLite3

protocol UpdateVC{
    func readValues()
}

class ViewController: UIViewController, UpdateVC {
    
    @IBOutlet weak var tableview: UITableView!
    
    var db: OpaquePointer?
    var reservationList = [Reservation]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? AddNewReservationViewController {
                destination.delegate = self
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableview.delegate = self
        tableview.dataSource = self
        
        // database file address
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ReservationDatabase.sqlite")
        
        // opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // creating the table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Reservations (id INTEGER PRIMARY KEY AUTOINCREMENT, dummyName TEXT, firstName TEXT, lastName TEXT, seats INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        print("Done Creating Table!")
        
        readValues()
    }
    
    // reading inputted values
    func readValues(){
        reservationList.removeAll()
        
        let queryString = "SELECT * FROM Reservations"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            print(id)
            let firstName = String(cString: sqlite3_column_text(stmt, 2))

            let seats = sqlite3_column_int(stmt, 3)
            
            reservationList.append(Reservation(Int(id), firstName, Int(seats)))
        }
        self.tableview.reloadData()
    }
    
    // deleting reservations from database
    func deleteItemFromList(itemId: Int32){
        
        let deleteStatementStirng = "DELETE FROM Reservations WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, itemId)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        print("delete")
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
        readValues()
    }
    
}

// delegate view
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let reservation: Reservation
        reservation = reservationList[indexPath.row]
        cell.textLabel?.text = reservation.name + ", " + String(reservation.seats) + " seats reserved."
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            deleteItemFromList(itemId: Int32(reservationList[indexPath.row].id))
            reservationList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

// base class for reservations
class Reservation {
    var id: Int
    var name: String
    var seats: Int
    
    init(_ id: Int, _ name: String, _ seats: Int){
        self.id = id
        self.name = name
        self.seats = seats
    }
}

