//
//  EditMedicationViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/5/22.
//

import UIKit
import Firebase
import FirebaseStorage

class EditMedicationViewController: UIViewController {

    @IBOutlet weak var editMedicationButton: UIButton!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var editDosageTextField: UITextField!
    @IBOutlet weak var editFrequencyTextField: UITextField!
    
    var medications: [Medications] = []
    var name: String = ""
    var dosage: String = ""
    var frequency: String = ""
    var documentID: String = ""
    var petID: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editNameTextField.text = name
        editDosageTextField.text = dosage
        editFrequencyTextField.text = frequency
    }

    @IBAction func editMedicationPressed(_ sender: UIButton) {
        if editNameTextField.text != "" { db.collection(Auth.auth().currentUser!.uid).document(documentID).updateData([
            "description": "medication",
            "medicationName": editNameTextField.text!,
            "medicationDosage": editDosageTextField.text ?? "",
            "medicationFrequency": editFrequencyTextField.text ?? "",
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
