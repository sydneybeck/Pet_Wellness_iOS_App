//
//  Database.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/12/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import UIKit

class Database {
    
    let db = Firestore.firestore()
    
    static func login(email: String, password: String, viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                displayAlert(title: "Error", message: error.localizedDescription, viewController: viewController)
            }
            completion(error)
        }
    }
    
    static func register(email: String, password: String, name: String, phone: String, viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                displayAlert(title: "Error", message: error.localizedDescription, viewController: viewController)
            }
            let timestamp = Timestamp()
            Firestore.firestore().collection("users").addDocument(data: [
                "email": email,
                "name": name,
                "phone": phone,
                "timestamp": timestamp
            ]) { (error) in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully.")
                }
            }
            completion(error)
        }
    }
    
    static func logout(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    static func displayAlert(title: String, message: String, viewController: UIViewController) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        
        dialogMessage.addAction(ok)
        
        viewController.present(dialogMessage, animated: true, completion: nil)
    }
}
