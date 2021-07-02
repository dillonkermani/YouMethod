//
//  HistoryViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 1/2/21.
//

import UIKit
import Firebase


var db:Firestore!
var documents = [NSDictionary]() // global list containing each of the user's past document entries.
var alreadyLoadedDocs = false // is used to prevent populating 'documents' multiple times.

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyCellColor: UIButton!
    @IBOutlet weak var historyCellLabel: UILabel!
    
    
    var db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!alreadyLoadedDocs) {
            db.collection("users").document((currentUser?.email)!).collection("entries").getDocuments() { (querySnapshot, err) in
                if err != nil {
                    print("Error getting documents: ", err.debugDescription)
                }else {
                    for document in querySnapshot!.documents {
                        // Adds each entry (document) from database to documents[].
                        print("DOCUMENT ADDED")
                        documents.append(document.data() as NSDictionary)
                    }
                    // Reloads data to account for document fetching latency.
                    self.tableView.reloadData()
                    alreadyLoadedDocs = true
                }
            }
        }
        
        
        // Table View setup
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
    }
    
    // This func runs before viewDidLoad()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of entries by signed in user present in database. (TODO: truncate for effeciency in the future)
        //testing
        return documents.count
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt IndexPath: IndexPath) {
        print("row ", IndexPath.row, " pressed!")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        
        // Set cell text
        cell.cellLabel.text = (documents[indexPath.row]["Date"] as! String)
        
        // Set cell color
        let id = documents[indexPath.row]["id"] as! String
        switch id {
            case "red":
                cell.cellColor.tintColor = UIColor.red
            case "yellow":
                cell.cellColor.tintColor = UIColor.yellow
            case "blue":
                cell.cellColor.tintColor = UIColor.blue
            case "green":
                cell.cellColor.tintColor = UIColor.green
            case "purple":
                cell.cellColor.tintColor = UIColor.purple
            default:
                print("Error: No color id found -> ", id)
            }
        
        
        return cell
    }
}
