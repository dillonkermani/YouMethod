//
//  HistoryViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 1/2/21.
//

import UIKit
import Firebase

var db:Firestore!

class HistoryViewController: UIViewController {
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        
        
    }
    
    @IBAction func ymIconPressed(_ sender: Any) {
        db.collection("users").document((currentUser?.email)!).collection("entries").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print("Error getting documents: ", err.debugDescription)
            }else {
                for document in querySnapshot!.documents {
                    print("Document data: ", document.data())
                }
            }
            
        }
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Todo: return the number of entries
        return 5
    }
    func tableView(_ tableView: UITableView, didSelectRowAt IndexPath: IndexPath) {
        print("row ", IndexPath.row, " pressed!")
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(indexPath.row), for: indexPath)
        return cell
    }
}
