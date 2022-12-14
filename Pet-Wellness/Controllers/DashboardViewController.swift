//
//  DashboardViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 11/14/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

protocol GoToPetProfileCellDelegator {
    func goToPetProfile(cell: PetCell)
}

protocol GoToEditPetCellDelegator {
    func goToEditPet(cell: PetCell)
}

class DashboardViewController: UIViewController, GoToPetProfileCellDelegator, GoToEditPetCellDelegator {
    
    @IBOutlet weak var reportsBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var petTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pets: [PetProfile] = []
    var filteredPets = [PetProfile]()
    let db = Firestore.firestore()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petTable.dataSource = self
        searchBar.delegate = self
        
        navigationItem.hidesBackButton = true
        
        petTable.register(UINib(nibName: "DefaultPetCell", bundle: nil), forCellReuseIdentifier: "DefaultPetCell")
        petTable.register(UINib(nibName: "PetCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        loadPets()
        checkReports()
    }
    
    func checkReports() {
        if case Auth.auth().currentUser?.email = "admin@gmail.com" {
            reportsBarButtonItem.isEnabled = true
        }
        else {
            reportsBarButtonItem.isEnabled = false
            reportsBarButtonItem.tintColor = UIColor(named: "CustomBeige")
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        Database.logout { (error) in
            if let error = error {
                print("Error signing out: %@", error)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func loadPets() {
        if Auth.auth().currentUser != nil {
            db.collection(Auth.auth().currentUser!.uid).whereField("description", isEqualTo: "petProfile")
                .addSnapshotListener { querySnapshot, error in
                    
                    self.pets = []
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                let id = doc.reference.documentID
                                let petName = data["name"] as? String
                                let petPhotoURL = data["photo"]  as? String
                                let petID = data["petID"] as? String
                                let species = data["species"]  as? String
                                let sex = data["sex"]  as? String
                                let weight = data["weight"]  as? String
                                let rabies = data["rabies"]  as? String
                                let birthday = data["birthday"]  as? String
                                let microchip = data["microchip"]  as? String
                                let newPet = PetProfile(documentID: id, petID: petID ?? "", url: petPhotoURL!, name: petName!, species: species!, sex: sex!, birthday: birthday ?? "", weight: weight ?? "", microchip: microchip ?? "", rabies: rabies ?? "")
                                self.pets.append(newPet)
                            }
                            
                            DispatchQueue.main.async {
                                self.petTable.reloadData()
                                let indexPath = IndexPath(row: self.pets.count - 1, section: 0)
                            }
                        }
                    }
                }
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension DashboardViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPets = pets.filter({ (pet) -> Bool in
            return pet.name.lowercased().contains(searchText.lowercased())
        })
        searching = true
        petTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        petTable.reloadData()
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredPets.count == 0 ? 1 : filteredPets.count
        } else {
            return pets.count == 0 ? 1 : pets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searching {
            if filteredPets.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultPetCell", for: indexPath)
                
                return cell
            }
            let pet = filteredPets[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! PetCell
            
            cell.medicationsButton.tag = indexPath.row
            cell.delegate = self
            cell.delegate2 = self
            cell.petNameLabel.text = pet.name
            cell.petImage.setImage(from: pet.url)
            return cell
        } else {
            if pets.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultPetCell", for: indexPath)
                
                return cell
            }
            let pet = pets[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! PetCell
            
            cell.medicationsButton.tag = indexPath.row
            cell.delegate = self
            cell.delegate2 = self
            cell.petNameLabel.text = pet.name
            cell.petImage.setImage(from: pet.url)
            return cell
        }
    }
    
    func goToPetProfile(cell: PetCell) {
        guard let indexPath = self.petTable.indexPath(for: cell) else {
            return
        }
        
        let pet: PetProfile
        if searching {
            pet = filteredPets[indexPath.row]
        } else {
            pet = pets[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "DashboardToPetProfile", sender: pet)
    }
    
    func goToEditPet(cell: PetCell) {
        guard let indexPath = self.petTable.indexPath(for: cell) else {
            return
        }
        
        let pet: PetProfile
        
        if searching {
            pet = filteredPets[indexPath.row]
        } else {
            pet = pets[indexPath.row]
        }
        self.performSegue(withIdentifier: "DashboardToEditPet", sender: pet)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DashboardToPetProfile" {
            let pet = sender as! PetProfile
            let secondView = segue.destination as! PetProfileViewController
            secondView.documentID = pet.documentID
            secondView.petID = pet.petID
            secondView.petName = pet.name
            secondView.photoURL = pet.url
        }
        
        if segue.identifier == "DashboardToEditPet" {
            let pet = sender as! PetProfile
            let secondView = segue.destination as! EditPetViewController
            secondView.documentID = pet.documentID
            secondView.petID = pet.petID
            secondView.inputName = pet.name
            secondView.inputProfilePhoto = pet.url
            secondView.inputSex = pet.sex
            secondView.inputBirthday = pet.birthday
            secondView.inputRabies = pet.rabies
            secondView.inputMicrochip = pet.microchip
            secondView.inputSpecies = pet.species
            secondView.inputWeight = pet.weight
        }
    }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if searching {
                    let documentID = filteredPets[indexPath.row].documentID
                    let event1 = db.collection(Auth.auth().currentUser!.uid).document(documentID)
                    event1.delete()
                    let petID = filteredPets[indexPath.row].petID
                    let event2 = db.collection("pets").whereField("petID", isEqualTo: petID)
                    event2.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print(error)
                        } else if let querySnapshot = querySnapshot {
                            for document in querySnapshot.documents {
                                document.reference.delete()
                            }
                        }
                    }
                    filteredPets.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    let documentID = pets[indexPath.row].documentID
                    let event1 = db.collection(Auth.auth().currentUser!.uid).document(documentID)
                    event1.delete()
                    let petID = pets[indexPath.row].petID
                    let event2 = db.collection("pets").whereField("petID", isEqualTo: petID)
                    event2.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print(error)
                        } else if let querySnapshot = querySnapshot {
                            for document in querySnapshot.documents {
                                document.reference.delete()
                            }
                        }
                    }
                    pets.remove(at: indexPath.row)
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
}

// MARK: - UIImage

extension UIImageView {
    func setImage(from urlAddress: String?) {
        guard let urlAddress = urlAddress, let url = URL(string: urlAddress) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
