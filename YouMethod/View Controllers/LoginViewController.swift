//
//  ViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 9/28/20.
//

import UIKit
import Firebase
import FirebaseAuth

var currentUser = Auth.auth().currentUser
var currentUserPass = String()

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //CoreData reference to managed object context
    
    //CoreData Users list
    //currently signed in user
    
    @IBOutlet weak var loginErrorLabel: UILabel!
    //View Controller Main Buttons
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPassButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    //View Controller Text Fields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordResetEmail: UITextField!
    
    //Parent, transparent, and tableView for password reset schematic
    @IBOutlet var loginParentView: UIView!
    var transparentView = UIView()
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var enterEmailLabel: UILabel!
    
    var tableViewOpen = false
    
    var canLoginUser = false
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        
        tableView.isHidden = true
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        //Dismisses keyboard when view is tapped
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
                view.addGestureRecognizer(Tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        loginErrorLabel.isHidden = true
        
        usernameTextField.keyboardType = UIKeyboardType.emailAddress
    
    }
    
    

    //executes regardless of text fields being full
    
    @IBAction func signInPressed(_ sender: Any) {
    
    }
    
    func canSignIn() -> Bool{
        signInButton.pulsate()
        var loginSuccessful = Bool()
        
        if usernameTextField.text != "" && passwordTextField.text != "" && usernameTextField.text!.contains("@") && usernameTextField.text!.contains(".") {
            
            let email = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: email, password: password) {
            (result, error) in
                
                if error != nil {
                    //couldnt sign in
                    self.loginErrorLabel.isHidden = false
                    self.loginErrorLabel.textColor = UIColor.red
                    self.loginErrorLabel.text = "Incorrect username or password."
                    print("ERROR SIGNING IN")
                    self.signInButton.shake()
                    loginSuccessful = false
                }else {
                    // Login Successful
                    print("Login successful!")
                    loginSuccessful = true
                    self.performSegue(withIdentifier: "CircleSegueLogin", sender: Any?.self)
                    currentUser = Auth.auth().currentUser
                    currentUserPass = self.passwordTextField.text!
                    
                }
            }
            return loginSuccessful
        }
        // If login fields do not pass requirements of first if statement
        self.loginErrorLabel.isHidden = false
        self.loginErrorLabel.textColor = UIColor.red
        self.loginErrorLabel.text = "Please enter a valid email address."
        signInButton.shake()
        return false
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "CircleSegueLogin" {
            if !canSignIn() {
                
                return false
            }
        }
        
        return true
        
    }
    
    // Only for visual animation purposes (may not do anything so check later)
    @IBAction func signUpPressed(_ sender: Any) {
        signUpButton.pulsate()
    }
    
    //username + password textfields pressed (changes border color) Add red borderColor when username/password detection is implemented.
    @IBAction func usertfPressed(_ sender: UITextField) {
        usernameTextField.layer.borderWidth = 2
        usernameTextField.layer.borderColor = hexStringToUIColor(hex: "30BECE").cgColor
        
        passwordTextField.layer.borderWidth = 0
    }
    @IBAction func passtfPressed(_ sender: Any) {
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.borderColor = hexStringToUIColor(hex: "30BECE").cgColor
        
        usernameTextField.layer.borderWidth = 0
    }
    //variable is not responsible for actual tableView height but will cause errors if changed
    var height: CGFloat = 250
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        
        //Reset message and text field
        enterEmailLabel.textColor = UIColor.white
        enterEmailLabel.text = "Enter Email:"
        passwordResetEmail.text = ""
        //Sets up 'transparentView' and adds it to the parent view.
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        transparentView.frame = self.view.frame
        loginParentView.addSubview(transparentView)
        //Programatically sets 'tableView' frame size and adds it to parent view
        let screenSize = UIScreen.main.bounds.size
        tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        loginParentView.addSubview(tableView)
        //Tap gesture recognizer to hide 'passResetView' when 'transparentView' is tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0 //prevents flashing effect when btnpressed
        //Animation for 'passResetView' emerging from bottom of screen
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            //Table View Items and Settings
            self.tableView.backgroundColor = self.hexStringToUIColor(hex: "30BECE")
            self.tableView.clipsToBounds = true
            self.tableView.layer.cornerRadius = 15
            self.tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.tableView.isHidden = false
            self.tableView.frame = CGRect(x: 0, y: screenSize.height - self.height, width: screenSize.width, height: self.height)
        }, completion: nil)
        tableViewOpen = true
    }
    
    //Checks whether email contains @ and . characters to close 'tableView' else button shake animation.
    @IBAction func sendRequestPressed(_ sender: Any) {
        let email = passwordResetEmail.text
        if email!.contains("@") && email!.contains(".") && email != ""{
            Auth.auth().sendPasswordReset(withEmail: email!, completion: { (err) in
                if err != nil {
                    self.sendRequestButton.shake()
                    self.enterEmailLabel.textColor = UIColor.red
                    self.enterEmailLabel.text = err?.localizedDescription
                }else {
                    self.onClickTransparentView()

                }
            })
        }else{
            sendRequestButton.shake()
            enterEmailLabel.textColor = UIColor.red
            enterEmailLabel.text = "Please enter a valid email address:"
        }
        
    }
    //Hides 'passResetView' if user swipes it away
    @IBAction func passResetSwipeDown(_ sender: Any) {
        onClickTransparentView()
    }
    //'passResetView' dismissal animation.
    @objc func onClickTransparentView() {
        tableViewOpen = false
        let screenSize = UIScreen.main.bounds.size
        DismissKeyboard()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.isHidden = false //seems counterintuitive but this allows for the fluid dismissal animation
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: nil)
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

    @objc func DismissKeyboard() {
        if tableViewOpen {
            onClickTransparentView()
            view.endEditing(true)
        }else {
            view.endEditing(true)

        }
            
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if tableViewOpen {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.tableView.frame.origin.y == 417 {
                    self.tableView.frame.origin.y -= keyboardSize.height

                }
            }
        }
    }
    //Never executes
    @objc func keyboardWillHide(notification: NSNotification) {
        if tableViewOpen {
            if self.view.frame.origin.y != 0 {
                self.tableView.frame.origin.y = 0
                self.tableView.isHidden = false
                
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
    
    
    


}

extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.25
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = false
        pulse.repeatCount = 0
        pulse.initialVelocity = 0
        pulse.damping = 0.5
        
        layer.add(pulse, forKey: nil)
    }
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
    }
    
}

