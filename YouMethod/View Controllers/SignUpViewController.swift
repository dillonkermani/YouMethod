//
//  SignUpViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 11/5/20.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    var canAddUser = false
    
    @IBOutlet var parentView: UIView!
    // Sign up text view data
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var signUpTextViews: [UITextField]!
    // Individual outlets for text views in above collection ^
    @IBOutlet weak var firstnameTextView: UITextField!
    @IBOutlet weak var lastnameTextView: UITextField!
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var passwordConfirmTextView: UITextField!
    
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var transparentButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transparentButton.isHidden = true
        signUpButton.layer.borderColor = UIColor.white.cgColor
        for tv in signUpTextViews {
            tv.self.layer.borderColor = UIColor.white.cgColor
            tv.self.layer.borderWidth = 2
            tv.self.backgroundColor = .clear
            tv.self.textColor = .white
            tv.self.layer.cornerRadius = 5
            tv.delegate = self
        }
        
        errorLabel.text = "All fields are required."
        errorLabel.textColor = UIColor.white
        
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
                view.addGestureRecognizer(Tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        emailTextView.keyboardType = UIKeyboardType.emailAddress
        
    }
    
    // Checks fields and validates taht the data is correct. Returns nil if everyhting is correct.
    func validateFields() -> String? {
        //Check that all fields are filled in
                
        return nil
    }
    
    //executes regardless of text fields being full
    @IBAction func signUpPressed(_ sender: Any) {
        
        
        
        
    }
    
    func canSignUp() -> Bool {
        var signUpSuccessful = false
        let firstName = firstnameTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastnameTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordConfirm = passwordConfirmTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        for tv in signUpTextViews {
            if tv.text == "" { //add && statements here if error doesn't need to be thrown for optional data entry(if there is any)
                tv.self.layer.borderColor = UIColor.red.cgColor
                signUpButton.shake()
                return false
            }
        }
        if !(email.contains("@") && email.contains(".")) {
            // Sign up email is not a valid email address
            errorLabel.text = "Please enter a valid email address."
            errorLabel.textColor = UIColor.red
            emailTextView.self.layer.borderColor = UIColor.red.cgColor
            signUpButton.shake()
            return false
        }
        if password.count < 6 {
            errorLabel.text = "Password must be at least 6 characters."
            errorLabel.textColor = UIColor.red
            passwordTextView.self.layer.borderColor = UIColor.red.cgColor
            signUpButton.shake()
            return false
        }
        if password != passwordConfirm {
            // If confirm password != password
            errorLabel.text = "Password fields to not match."
            errorLabel.textColor = UIColor.red
            passwordTextView.self.layer.borderColor = UIColor.red.cgColor
            passwordConfirmTextView.self.layer.borderColor = UIColor.red.cgColor
            signUpButton.shake()
            return false
        }
        
        // Validate the fields
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            //check for error while creating user
            if err != nil {
                print("ERROR CREATING USER: ", err!)
                
            }
            else {
                //User was cerated successfully, now store the first name and the last name
                let db = Firestore.firestore()
                
                db.collection("users").document(email).setData(["firstName":firstName, "lastName":lastName, "email":email, "password":password, "uid":result!.user.uid] )
                
                Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                    
                    if error != nil {
                        //couldnt sign in
                        print("ERROR SIGNING IN")
                        
                    }else {
                        // Login Successful
                        print("Login successful!")
                        signUpSuccessful = true
                        self.performSegue(withIdentifier: "CircleSegue1", sender: Any?.self)
                        currentUser = Auth.auth().currentUser
                        currentUserPass =  self.passwordTextView.text!
                    }
                }
            }
        }
        return signUpSuccessful
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !canSignUp() {
            return false
        }
        
        return true
    }
    
    @IBAction func changeTextViewColor(_ sender: UITextField) {
        let tag = sender.tag
        for tv in signUpTextViews {
            if tv.tag == tag{
                tv.self.layer.borderColor = hexStringToUIColor(hex: "30BECE").cgColor
            }else {
                tv.self.layer.borderColor = UIColor.white.cgColor
            }
            
        }
    }
    
    @IBAction func transparentButtonPressed(_ sender: Any) {
        transparentButton.isHidden = true
    }
    
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
    }

    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


