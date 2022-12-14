//
//  EditMedicationViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/5/22.
//

import UIKit
import Firebase
import FirebaseStorage

class AddMedicationViewController: UIViewController {
    
    @IBOutlet weak var addMedicationButton: UIButton!
    @IBOutlet weak var addNameTextField: UITextField!
    @IBOutlet weak var addDosageTextField: UITextField!
    @IBOutlet weak var addFrequencyTextField: UITextField!
    
    let db = Firestore.firestore()
    var documentID: String = ""
    var petID: String = ""
    var medications: [Medications] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addMedicationsButtonPressed(_ sender: UIButton) {
        if addNameTextField.text != "" { db.collection(Auth.auth().currentUser!.uid).addDocument(data:[
            "description": "medication",
            "petID": petID,
            "medicationName": addNameTextField.text!,
            "medicationDosage": addDosageTextField.text ?? "",
            "medicationFrequency": addFrequencyTextField.text ?? "",
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        } else {
            displayAlert(title: "Error", message: "Please add a medication name")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        
        dialogMessage.addAction(ok)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
}
