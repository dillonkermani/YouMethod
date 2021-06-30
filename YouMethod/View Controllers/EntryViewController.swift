//
//  EntryViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 10/11/20.
//

import UIKit
import Firebase

// This dict will be written to the db upon completion of entry
var entryDataDict = Dictionary<String, Any>()

class EntryViewController: UIViewController, UITextViewDelegate {
    //Firestore
    var db:Firestore!
    
    //'Super View' view controller
    @IBOutlet var parentView: UIView!
    //Parent view controller for [entryViews]
    @IBOutlet weak var entryParentView: UIView!
    //Array of views for various entry prompts
    @IBOutlet var entryViews: [UIView]!
    var viewIndex = 0 //Indicates index of which [entryViews] view is currently being shown
    //Parent view 'centerX' constraint for viewDidAppear() animation
    @IBOutlet weak var entryParentViewCenterX: NSLayoutConstraint!
    //Bottom dock buttons
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var backButton: CustomButton!
    //Outlets for entryViews[0]
    @IBOutlet var hyfButtons: [UIButton]!
    @IBOutlet weak var hyfStackView: UIStackView!
    @IBOutlet weak var hyfLabel: UILabel!
    //Outlets for entryViews[1]
    @IBOutlet weak var mentalStateStackView: UIStackView!
    //Outlets for entryViews[7]
    @IBOutlet weak var textView: UITextView!
    var placeholderLabel : UILabel!
    //Progress circles outlets
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet var progressCircles: [UIButton]!
    @IBOutlet weak var transparentButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Firestore
        db = Firestore.firestore()
        
        hyfLabel.isHidden = true
        //Hides all views except for first entry view.
        for view in entryViews {
            view.isHidden = true
        }
        entryViews[0].isHidden = false
        //Causes entryParentView to load from left of view
        entryParentViewCenterX.constant -= view.bounds.width
        // Set's storyTextView placeholder
        textView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What's on your mind...?"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        //Initializes progressCircles as white circles
        for circle in progressCircles {
            circle.backgroundColor = UIColor.white
            
        // Keyboard adjustment functionality
            let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
                    view.addGestureRecognizer(Tap)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Animation for entryParentView to enter from left and bounce.
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.entryParentViewCenterX.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        //Unhides following UI elements to make animation look cleaner.
        progressStackView.isHidden = false
        hyfStackView.isHidden = false
        hyfLabel.isHidden = false
            
    }
    
    func textViewDidChange(_ textView: UITextView) {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    
    func nextView() {
        if viewIndex < entryViews.count - 1 { //Fault tolerance for indexOutOfBounds error with viewIndex
            UIView.transition(from: entryViews[viewIndex], to: entryViews[viewIndex+1], duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews])
            progressCircles[viewIndex].backgroundColor = UIColor.green
        }
        viewIndex += 1
        
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        nextView()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        if viewIndex > 0 { //Fault tolerance for indexOutOfBounds error with viewIndex
            UIView.transition(from: entryViews[viewIndex], to: entryViews[viewIndex-1], duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews])
            progressCircles[viewIndex-1].backgroundColor = UIColor.yellow
            viewIndex -= 1
                    
        }
        
    }
    
    // Keyboard adjust view functionality.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
             if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
                nextField.becomeFirstResponder()
             } else {
                // Not found, so remove keyboard.
                DismissKeyboard()
             }
             // Do not add a line break
             return false
    }
    //keyboard dismissal when return pressed(maybe?)
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        DismissKeyboard()
    }

    @objc func DismissKeyboard() {
            keyboardIsShowing = false
            parentView.frame.origin.y = 0
            view.endEditing(true)
    }
    
    var keyboardIsShowing = false
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !keyboardIsShowing {
            keyboardIsShowing = true
            transparentButton.isHidden = false
            if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                self.parentView.frame.origin.y -= (parentView.frame.height * 0.13)

                }
            }
        }
    
    @IBAction func transparentButtonPressed(_ sender: Any) {
        transparentButton.isHidden = true
        DismissKeyboard()
    }
    
    
    
    // MMenu input to database
    
    // Mood View (How are you feeling?)
    @IBAction func excellentPressed(_ sender: Any) {
        entryDataDict["Mood"] = "Excellent"
        nextView()
    }
    @IBAction func goodPressed(_ sender: Any) {
        entryDataDict["Mood"] = "Good"
        nextView()
    }
    @IBAction func okPressed(_ sender: Any) {
        entryDataDict["Mood"] = "OK"
        nextView()
    }
    @IBAction func badPressed(_ sender: Any) {
        entryDataDict["Mood"] = "Bad"
        nextView()
    }
    @IBAction func awfulPressed(_ sender: Any) {
        entryDataDict["Mood"] = "Awful"
        nextView()
    }
    
    // State View (Current mental state?)
    @IBAction func stillPressed(_ sender: Any) {
        entryDataDict["Mental State"] = "Still"
        nextView()
    }
    @IBAction func calmPressed(_ sender: Any) {
        entryDataDict["Mental State"] = "Calm"
        nextView()
    }
    @IBAction func busyPressed(_ sender: Any) {
        entryDataDict["Mental State"] = "Busy"
        nextView()
    }
    @IBAction func ok1Pressed(_ sender: Any) {
        entryDataDict["Mental State"] = "OK"
        nextView()
    }
    @IBAction func agitatedPressed(_ sender: Any) {
        entryDataDict["Mental State"] = "Agitated"
        nextView()
    }
    
    // Energy View (Current Energy Level?)
    @IBAction func veryhighPressed(_ sender: Any) {
        entryDataDict["Energy Level"] = "Very High"
        nextView()
    }
    @IBAction func highPressed(_ sender: Any) {
        entryDataDict["Energy Level"] = "High"
        nextView()
    }
    @IBAction func mediumPressed(_ sender: Any) {
        entryDataDict["Energy Level"] = "Medium"
        nextView()
    }
    @IBAction func lowPressed(_ sender: Any) {
        entryDataDict["Energy Level"] = "Low"
        nextView()
    }
    @IBAction func verylowPressed(_ sender: Any) {
        entryDataDict["Energy Level"] = "Very Low"
        nextView()
    }
    
    //Pleasure View (Sources of Pleasure)
    @IBOutlet var pleasureTextViews: [UITextField]! // Add kv pairs to {entryDataDict} when submit pressed
    
    //Pain View (Sources of Pain)
    @IBOutlet var painTextViews: [UITextField]! // Add kv pairs to {entryDataDict} when submit pressed
    
    //Craving View (Current Cravings)
    @IBOutlet var cravingsTextViews: [UITextField]! // Add kv pairs to {entryDataDict} when submit pressed
    
    //Aversion View (Current Aversions)
    @IBOutlet var aversionsTextViews: [UITextField]! // Add kv pairs to {entryDataDict} when submit pressed
    
    
    // Submit Entry Pressed (IMPORTANT)
    func populateDict() {
        var l:[String] = [] // List of text view entries
        
        for pleasure in pleasureTextViews {
            l.append(pleasure.text!)
        }
        entryDataDict["Sources of Pleasure"] = l
        l.removeAll()
        
        for pain in painTextViews {
            l.append(pain.text!)
        }
        entryDataDict["Sources of Pain"] = l
        l.removeAll()
        
        for craving in cravingsTextViews {
            l.append(craving.text!)
        }
        entryDataDict["Cravings"] = l
        l.removeAll()
        
        for aversion in aversionsTextViews {
            l.append(aversion.text!)
        }
        entryDataDict["Aversions"] = l
        l.removeAll()
        
        entryDataDict["Story"] = textView.text!
        
        entryDataDict["Date"] = date
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SubmitEntrySegue" {
            if self.viewIndex == 8 {
                populateDict()
                return true
            }
            
        }
       return false
    }
    // Add all kv pairs to below document
    // db.collection("users").document((currentUser?.email)!).collection("entries").document(date).setData(["Mood":"excellent"])
 
    
}

