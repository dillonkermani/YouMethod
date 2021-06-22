//
//  MMenuViewController.swift
//  YouMethod
//
//  Created by Dillon Kermani on 10/7/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

//current date
var date = String()

class MMenuViewController: UIViewController {

    //Firestore variables
    var db:Firestore!
    //Views for discover tab
    @IBOutlet weak var discoverView: UIView!
    @IBOutlet weak var discoverFlipView: UIView!
    //Views for share view
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareFlipView: UIView!
    //Back button to flip 'discoverView' or 'shareView'
    @IBOutlet weak var invisBackButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var plusButton: CustomButton!
    //Required for plus button breathing effect.
    var pulsatingLayer: CAShapeLayer!
    let circularPath = UIBezierPath(arcCenter: .zero, radius: 27, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        plusButton.pulsate()
        //Plus button breathing effect code.
        pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circularPath.cgPath
        pulsatingLayer.strokeColor = UIColor.systemGray5.cgColor
        pulsatingLayer.lineWidth = 10
        pulsatingLayer.fillColor = UIColor.clear.cgColor
        pulsatingLayer.lineCap = CAShapeLayerLineCap.round
        pulsatingLayer.position = plusButton.center
        view.layer.addSublayer(pulsatingLayer)
        view.bringSubviewToFront(plusButton)
        
        animatePulsatingLayer()
        
        //Firestore db setup
        db = Firestore.firestore()
        
    }
    
    
    
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        // Creates date: the hour:minute dayofweek, day month year of when entry is started
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm E, d MMM y"
        date = formatter3.string(from: Date())
        
        plusButton.pulsate()

        
    }
    
    //Function for breathing plus button
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
