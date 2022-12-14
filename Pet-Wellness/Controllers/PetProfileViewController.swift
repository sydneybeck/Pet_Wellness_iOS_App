//
//  PetProfileViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/2/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

protocol EditMedicationsCellDelegator {
    func goToEditMedication(cell: MedicationsCell)
}

protocol EditReminderCellDelegator {
    func goToEditReminder(cell: RemindersCell)
}

class PetProfileViewController: UIViewController,  EditMedicationsCellDelegator, EditReminderCellDelegator {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var medsTable: UITableView!
    @IBOutlet weak var remindersTable: UITableView!
    @IBOutlet weak var remindersButton: UIButton!
    @IBOutlet weak var medicationsButton: UIButton!
    
    var petName: String = "error"
    var documentID: String = ""
    var petID: String = ""
    var photoURL: String = ""
    var rowSelected : Int?
    
    var medications: [Medications] = []
    var reminders: [Reminders] = []
    var pet: [PetCellProfile] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        medsTable.dataSource = self
        remindersTable.dataSource = self
        
        petNameLabel.text = petName
        profileImage.setImage(from: photoURL)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        medicationsButton.layer.cornerRadius = medicationsButton.frame.size.height / 5
        remindersButton.layer.cornerRadius = remindersButton.frame.size.height / 5
        
        medsTable.register(UINib(nibName: "MedicationsCell", bundle: nil), forCellReuseIdentifier: "MedicationsCellReusableCell")
        medsTable.register(UINib(nibName: "DefaultMedicationsCell", bundle: nil), forCellReuseIdentifier: "DefaultMedicationsCell")
        
        remindersTable.register(UINib(nibName: "RemindersCellTableViewCell", bundle: nil), forCellReuseIdentifier: "RemindersCellReusableCell")
        remindersTable.register(UINib(nibName: "DefaultRemindersCell", bundle: nil), forCellReuseIdentifier: "DefaultRemindersCell")
        
        loadMedications()
        loadReminders()
    }
    
    @IBAction func remindersButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "PetProfileToAddReminder", sender: petID)
    }
    
    @IBAction func medicationsButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "PetProfileToAddMedication", sender: petID)
    }
    
    func goToEditMedication(cell: MedicationsCell) {
        guard let indexPath = self.medsTable.indexPath(for: cell) else {
            return
        }
        self.performSegue(withIdentifier: "PetProfileToEditMedication", sender: indexPath)
    }
    
    func goToEditReminder(cell: RemindersCell) {
        guard let indexPath = self.remindersTable.indexPath(for: cell) else {
            return
        }
        self.performSegue(withIdentifier: "PetProfileToEditReminder", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PetProfileToEditMedication" {
            let selectedRow = sender as! IndexPath
            let secondView = segue.destination as! EditMedicationViewController
            let medication = medications[selectedRow.row]
            secondView.documentID = medication.documentID
            secondView.petID = medication.petID
            secondView.name = medication.medicationName
            secondView.dosage = medication.medicationDosage ?? ""
            secondView.frequency = medication.medicationFrequency ?? ""
        }
        if segue.identifier == "PetProfileToEditReminder" {
            let selectedRow = sender as! IndexPath
            let secondView = segue.destination as! EditReminderViewController
            let reminder = reminders[selectedRow.row]
            secondView.documentID = reminder.documentID
            secondView.petID = reminder.petID
            secondView.inputName = reminder.reminderName
            secondView.inputDate = reminder.reminderDate
        }
        if segue.identifier == "PetProfileToAddReminder" {
            let petID = sender as! String
            let secondView = segue.destination as! AddReminderViewController
            secondView.petID = petID
        }
        if segue.identifier == "PetProfileToAddMedication" {
            let petID = sender as! String
            let secondView = segue.destination as! AddMedicationViewController
            secondView.petID = petID
        }
    }
    
    func loadMedications() {
        if Auth.auth().currentUser != nil {
            db.collection(Auth.auth().currentUser!.uid)
                .whereField("description", isEqualTo: "medication")
                .whereField("petID", isEqualTo: petID )
                .addSnapshotListener { [self] querySnapshot, error in
                    self.medications = []
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                let documentID = doc.reference.documentID
                                let petID = data["petID"] as! String
                                let medicationName = data["medicationName"] as? String
                                let medicationDosage = data["medicationDosage"] as? String
                                let medicationFrequency = data["medicationFrequency"] as? String
                                let newMedication = Medications(documentID: documentID, petID: petID, medicationName: medicationName!, medicationDosage: medicationDosage, medicationFrequency: medicationFrequency)
                                self.medications.append(newMedication)
                            }
                            
                            DispatchQueue.main.async {
                                self.medsTable.reloadData()
                                let indexPath = IndexPath(row: self.medications.count - 1, section: 0)
                            }
                        }
                    }
                }
        }
    }
    
    func loadReminders() {
        if Auth.auth().currentUser != nil {
            db.collection(Auth.auth().currentUser!.uid)
                .whereField("description", isEqualTo: "reminder")
                .whereField("petID", isEqualTo: petID )
                .addSnapshotListener { [self] querySnapshot, error in
                    self.reminders = []
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                let documentID = doc.reference.documentID
                                let petID = data["petID"] as! String
                                let reminderName = data["reminderName"] as? String
                                let reminderDate = data["reminderDate"] as? String
                                let newReminder = Reminders(documentID: documentID, petID: petID, reminderName: reminderName!, reminderDate: reminderDate!)
                                self.reminders.append(newReminder)
                            }
                            
                            DispatchQueue.main.async {
                                self.remindersTable.reloadData()
                                let indexPath = IndexPath(row: self.reminders.count - 1, section: 0)
                            }
                        }
                    }
                }
        }
    }
}

// MARK: - UITableViewDataSource

extension PetProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == medsTable {
//            return medications.count
            return medications.count == 0 ? 1 : medications.count
        }
        if tableView == remindersTable {
//            return reminders.count
            return medications.count == 0 ? 1 : medications.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == medsTable {
            if medications.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultMedicationsCell", for: indexPath)
                
                return cell
            } else {
                let medication = medications[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationsCellReusableCell", for: indexPath) as! MedicationsCell
                
                cell.delegate = self
                cell.medicationNameLabel.text = medication.medicationName
                
                return cell
            }
        }
        if tableView == remindersTable {
            if reminders.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultRemindersCell", for: indexPath)
                
                return cell
            } else {
                let reminder = reminders[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "RemindersCellReusableCell", for: indexPath) as! RemindersCell
                
                cell.delegate = self
                cell.nameLabel.text = reminder.reminderName
                cell.dateLabel.text = reminder.reminderDate
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tableView == medsTable {
                let firebaseKey = medications[indexPath.row].documentID
                let eventRef = db.collection(Auth.auth().currentUser!.uid).document(firebaseKey)
                eventRef.delete()
                medications.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if tableView == remindersTable {
                let firebaseKey = reminders[indexPath.row].documentID
                let eventRef = db.collection(Auth.auth().currentUser!.uid).document(firebaseKey)
                eventRef.delete()
                reminders.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

