//
//  SettingsViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 12/30/20.
//

import UIKit
import FirebaseAuth
import Firebase

class SettingsViewController: UIViewController {
    
    //Firestore
    var db:Firestore!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var settingsEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        tableView.delegate = self
        tableView.dataSource = self

        // Turned off for testing
        //settingsEmailLabel.text = currentUser?.email
    }

    @IBAction func ymlogoPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, didSelectRowAt IndexPath: IndexPath) {
        print("row ", IndexPath.row, " pressed!")
        // If Edit Email pressed
        if IndexPath.row == 0 {
            let alert = UIAlertController(title: "Verification", message: "Please Enter Current Password:", preferredStyle: .alert)
            alert.addTextField()
            alert.addTextField()
            alert.textFields![0].placeholder = "Current password"
            alert.textFields![0].isSecureTextEntry = true
            alert.textFields![1].placeholder = "New Email Address"
            alert.textFields![1].keyboardType = UIKeyboardType.emailAddress
            // action buttons (cancel or update)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
                // Cancel (Do nothing)
                print("cancel")
            }))
                            
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: {(action) in
                 // Update email address
                let currentPass = alert.textFields![0].text
                let newEmail = alert.textFields![1].text
                // Error handling
                // If fail
                if currentPass != currentUserPass {
                    alert.message = "Incorrect password"
                    self.present(alert, animated: true)
                
                // If fail
                } else if !(newEmail!.contains("@") && newEmail!.contains(".")) || newEmail! == "" {
                    alert.message = "Please enter a valid new email"
                    self.present(alert, animated: true)
                
                // If success
                }else if (currentPass == currentUserPass) && (newEmail!.contains("@") && newEmail!.contains(".")) && newEmail != "" {
                    currentUser?.updateEmail(to: newEmail!, completion: { (err) in
                        if err != nil{
                            print("couldn't update user email: ",err!)
                        }else {
                            self.settingsEmailLabel.text = newEmail
                        }
                    })
                }
            }))
            if !alert.isViewLoaded {
                self.present(alert, animated: true)
            }
            
        }
        // If reset password pressed
        if IndexPath.row == 1 {
            let alert = UIAlertController(title: "Verification", message: "Please Enter Current Password:", preferredStyle: .alert)
            alert.addTextField()
            alert.addTextField()
            alert.textFields![0].placeholder = "Current password"
            alert.textFields![0].isSecureTextEntry = true
            alert.textFields![1].placeholder = "New Password"
            alert.textFields![1].keyboardType = UIKeyboardType.emailAddress
            // action buttons (cancel or update)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
                // Cancel (Do nothing)
                print("cancel")
            }))
                            
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: {(action) in
                 // Update email address
                let currentPass = alert.textFields![0].text
                let newPass = alert.textFields![1].text
                // Error handling
                // If fail
                if currentPass != currentUserPass {
                    alert.message = "Incorrect password"
                    self.present(alert, animated: true)
                
                } else if newPass!.count < 6 {
                    // password too short
                    alert.message = "Password must be longer than 6 characters"
                    self.present(alert, animated: true)
                
                // If success
                } else if (newPass!.count >= 6) && (currentPass == currentUserPass) {
                    currentUser?.updatePassword(to: newPass!, completion: { (err) in
                        if err != nil{
                            print("couldn't update user password: ",err!)
                        }else {
                            print("successfully updated password for user: ", currentUser?.email!)
                        }
                    })
                }
            }))
            if !alert.isViewLoaded {
                self.present(alert, animated: true)
            }
        }
        // Sign out pressed (not working right now)
//        if IndexPath.row == 4 {
//            do {
//                try Auth.auth().signOut()
//                let loginVC = LoginViewController()
//                self.present(loginVC, animated: true, completion: nil)
//            }catch {
//                print("unable to log user out")
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(indexPath.row), for: indexPath)
        return cell
    }
}
