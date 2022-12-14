//
//  ReportsViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/14/22.
//

import UIKit
import Firebase
import FirebaseStorage

class ReportsViewController: UIViewController, UITabBarDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var petReportsButton: UIButton!
    @IBOutlet weak var mostPopularSpeciesTitleLabel: UILabel!
    @IBOutlet weak var userReportsButton: UIButton!
    @IBOutlet weak var numberOfPetsTitleLabel: UILabel!
    @IBOutlet weak var numberOfSpeciesTitleLabel: UILabel!
    @IBOutlet weak var UserView: UIView!
    @IBOutlet weak var petsView: UIView!
    @IBOutlet weak var numberOfUsersResultsLabel: UILabel!
    @IBOutlet weak var newUsersThisMonthLabel: UILabel!
    @IBOutlet weak var numberOfPetsLabel: UILabel!
    @IBOutlet weak var numberOfSpeciesLabel: UILabel!
    @IBOutlet weak var mostPopularSpeciesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petsView.isHidden = true
        
        userReportsButton.tag = 1
        petReportsButton.tag = 2
        
        loadUserStats()
        loadPetStats()
        
        petReportsButton.layer.cornerRadius = petReportsButton.frame.size.height / 5
        userReportsButton.layer.cornerRadius = userReportsButton.frame.size.height / 5
    }
    
    func loadUserStats() {
        countUsers { count in
            self.numberOfUsersResultsLabel.text = String(describing: count)
        }
        
        countUsersLastMonth { count in
            self.newUsersThisMonthLabel.text = String(describing: count)
        }
    }
    
    func loadPetStats() {
        countPets { count in
            self.numberOfPetsLabel.text = String(describing: count)
        }
        
        countNumberOfSpecies { totalSpeciesCount in
            self.numberOfSpeciesLabel.text = String(describing: totalSpeciesCount)
        }
        
        mostPopularSpecies { mostCommonSpecies in
            self.mostPopularSpeciesLabel.text = mostCommonSpecies
        }
    }
    
    @IBAction func userReportsButtonPressed(_ sender: UIButton) {
        UserView.isHidden = false
        petsView.isHidden = true
    }
    
    @IBAction func petReportsButtonPressed(_ sender: UIButton) {
        UserView.isHidden = true
        petsView.isHidden = false
    }
    
    func countUsers(completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        var count = 0
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                count = querySnapshot!.documents.count
                completion(count)
            }
        }
    }
    
    func countUsersLastMonth(completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        var count = 0
        
        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let today = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        db.collection("users").whereField("timestamp", isGreaterThan: monthAgo!)
            .whereField("timestamp", isLessThan: today!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    count = querySnapshot!.documents.count
                    completion(count)
                }
            }
    }
    
    func countPets(completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        var count = 0
        
        db.collection("pets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                count = querySnapshot!.documents.count
                completion(count)
            }
        }
    }
    
    func countNumberOfSpecies(completion: @escaping (Int) -> Void) {
        let database = Firestore.firestore()
        var totalSpeciesCount = 0
        
        let species = ["Cat", "Dog", "Bird", "Ferret", "Horse", "Rabbit", "Reptile", "Rodent", "Fish", "Other"]
        let dispatchGroup = DispatchGroup()
        
        for sp in species {
            dispatchGroup.enter()
            
            database.collection("pets").whereField("species", isEqualTo: sp).getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    let count = querySnapshot!.documents.count
                    if count > 0 {
                        totalSpeciesCount += 1
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(totalSpeciesCount)
        }
    }
    
    
    
    func mostPopularSpecies(completion: @escaping (String) -> Void) {
        let database = Firestore.firestore()
        var highestCount = 0
        var mostCommonSpecies: [String] = []
        
        let species = ["Cat", "Dog", "Bird", "Ferret", "Horse", "Rabbit", "Reptile", "Rodent"]
        
        database.collection("pets").whereField("species", in: species).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                var speciesCounts: [String: Int] = [:]
                
                for document in querySnapshot!.documents {
                    let species = document.data()["species"] as! String
                    
                    if speciesCounts[species] == nil {
                        speciesCounts[species] = 1
                    } else {
                        speciesCounts[species]! += 1
                    }
                    
                    let count = speciesCounts[species]!
                    if count > highestCount {
                        mostCommonSpecies.removeAll()
                        highestCount = count
                        mostCommonSpecies = [species]
                    } else if count == highestCount {
                        mostCommonSpecies.append(species)
                    }
                }
            }
            completion(mostCommonSpecies.joined(separator: ", "))
        }
    }
}

