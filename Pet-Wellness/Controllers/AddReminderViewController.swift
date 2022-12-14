//
//  AddReminderViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/7/22.
//

import UIKit
import Firebase
import FirebaseStorage

class AddReminderViewController: UIViewController {
    
    @IBOutlet weak var addReminderButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addNameTextField: UITextField!
    
    let db = Firestore.firestore()
    var documentID: String = ""
    var petID: String = ""
    var reminders: [Reminders] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        let formattedDate = formatter.string(from: datePicker.date)
        return formattedDate
    }
    
    @IBAction func addReminderPressed(_ sender: UIButton) {
        if addNameTextField.text != "" { db.collection(Auth.auth().currentUser!.uid).addDocument(data:[
            "description": "reminder",
            "petID": petID,
            "reminderName": addNameTextField.text!,
            "reminderDate": formatDate()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        } else {
            displayAlert(title: "Error", message: "Please add a reminder name")
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
