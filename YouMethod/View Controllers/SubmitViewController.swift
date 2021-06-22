//
//  SubmitViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 1/2/21.
//

import UIKit
import Firebase
import SAConfettiView

class SubmitViewController: UIViewController {
    //Firestore ref
    var db:Firestore!
    @IBOutlet weak var identifierView: UIView!
    
    @IBOutlet weak var toHomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.type = .Confetti
                
        view.addSubview(confettiView)
        confettiView.startConfetti()
        view.bringSubviewToFront(toHomeButton)
        view.bringSubviewToFront(identifierView)
        
    }
    
    // Identifier selection
    @IBAction func redIDPressed(_ sender: Any) {
        entryDataDict["id"] = "red"
    }
    @IBAction func yellowIDPressed(_ sender: Any) {
        entryDataDict["id"] = "yellow"
    }
    @IBAction func blueIDPressed(_ sender: Any) {
        entryDataDict["id"] = "blue"
    }
    @IBAction func greenIDPressed(_ sender: Any) {
        entryDataDict["id"] = "green"
    }
    @IBAction func purpleIDPressed(_ sender: Any) {
        entryDataDict["id"] = "purple"
    }
    
    // Updates firebase with {entryDataDict} and returns to home vc
    func addFirebaseEntry() {

    db.collection("users").document((currentUser?.email)!).collection("entries").document(date).setData(entryDataDict)

        
        
        
        
    }
    
    @IBAction func returnHomePressed(_ sender: Any) {
        addFirebaseEntry()
        print(entryDataDict)
    }
    

    

}
