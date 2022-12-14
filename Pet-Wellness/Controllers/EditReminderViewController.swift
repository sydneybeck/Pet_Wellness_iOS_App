//
//  EditReminderViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/7/22.
//

import UIKit
import Firebase
import FirebaseStorage

class EditReminderViewController: UIViewController {
    
    @IBOutlet weak var editReminderButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var editReminderTextField: UITextField!
    
    var inputName: String = ""
    var inputDate: String = ""
    var documentID: String = ""
    var petID: String = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let formattedInputDate = formatter.date(from: inputDate) {
            datePicker.date = formattedInputDate
        }
        editReminderTextField.text = inputName
    }
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        let formattedDate = formatter.string(from: datePicker.date)
        return formattedDate
    }
    
    @IBAction func editReminderPressed(_ sender: Any) {
        if editReminderTextField.text != "" { db.collection(Auth.auth().currentUser!.uid).document(documentID).updateData([
            "description": "reminder",
            "reminderName": editReminderTextField.text!,
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

