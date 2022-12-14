//
//  AddPetViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 11/15/22.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftUI

class AddPetViewController: UIViewController {
    
    @IBOutlet weak var rabiesTextField: UITextField!
    @IBOutlet weak var microchipTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var speciesPicker: UIPickerView!
    @IBOutlet weak var sexPicker: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addProfilePhotoButton: UIButton!
    
    var speciesData: [String] = [String]()
    var sexData: [String] = [String]()
    var speciesName: String = ""
    var sexSelection: String = ""
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let petID = String(arc4random_uniform(100000))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.speciesPicker.delegate = self
        self.speciesPicker.delegate = self
        self.sexPicker.delegate = self
        self.sexPicker.delegate = self
        
        speciesData = ["", "Cat", "Dog", "Bird", "Ferret", "Horse", "Rabbit", "Reptile", "Rodent", "Fish", "Other"]
        sexData = ["", "Male", "Male - Neutered", "Female", "Female - Spayed"]
        
        addProfilePhotoButton.layer.cornerRadius =  addProfilePhotoButton.frame.size.height/2
        
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapScreen)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+300)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addPhotoPressed(_ sender: UIButton) {
        pickImage()
    }
    
    func getDate() -> String {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMMM-dd"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        return selectedDate
    }
    
    
    func setDefaultPhoto() {
        let image = UIImage(systemName: "pawprint.circle")
        guard let imageData = image!.pngData() else {
            print("Error converting to PNG data")
            return
        }
        let fileRef = storage.child("petProfileImages/\(UUID().uuidString).png")
        fileRef.putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print(error!)
                print("Failed to upload")
                return
            }
            
            fileRef.downloadURL(completion: { url, error in
                guard let url = url,  error == nil else {
                    print(error!)
                    return
                }
                print(url)
                let urlString = url.absoluteString
                UserDefaults.standard.set(urlString, forKey: "url")
                
                let finalURL = URL(string: urlString)
                let task = URLSession.shared.dataTask(with: finalURL!, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        print(error!)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                    }
                })
                
                task.resume()
            })
            return
        })
    }
    
    @IBAction func addPetPressed(_ sender: UIButton) {
        if !addProfilePhotoButton.isSelected {
            setDefaultPhoto()
        }
        
        if nameTextField.text != "" && speciesName != "" && sexSelection != "" {
            db.collection(Auth.auth().currentUser!.uid).addDocument(data: [
                "description": "petProfile",
                "photo": UserDefaults.standard.object(forKey: "url") ?? "",
                "name": nameTextField.text!,
                "petID": petID,
                "species": speciesName,
                "sex": sexSelection,
                "birthday": getDate(),
                "weight": weightTextField.text!,
                "microchip": microchipTextField.text!,
                "rabies": rabiesTextField.text!
            ]) { [self] err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    db.collection("pets").addDocument(data: [
                        "petID": petID,
                        "species": speciesName
                    ])
                    self.performSegue(withIdentifier: "AddPetToDashboard", sender: self)
                }
            }
        } else {
            Database.displayAlert(title: "Error", message: "Please add a name, species, and sex", viewController: self)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddPetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func pickImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        let fileRef = storage.child("petProfileImages/\(UUID().uuidString).jpg")
        fileRef.putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            fileRef.downloadURL(completion: { url, error in
                guard let url = url,  error == nil else {
                    print(error!)
                    return
                }
                let urlString = url.absoluteString
                UserDefaults.standard.set(urlString, forKey: "url")
                
                let finalURL = URL(string: urlString)
                let task = URLSession.shared.dataTask(with: finalURL!, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        print(error!)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.addProfilePhotoButton.setImage(image, for: .normal)
                        self.addProfilePhotoButton.clipsToBounds = true
                        self.addProfilePhotoButton.layer.cornerRadius = self.addProfilePhotoButton.frame.size.height/2
                    }
                })
                
                task.resume()
            })
            return
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIPickerView

extension AddPetViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return speciesData.count
        }
        else {
            return sexData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return "\(speciesData[row])"
        }
        else {
            return "\(sexData[row])"
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            return speciesName = "\(speciesData[row])"
        }
        else {
            return sexSelection = "\(sexData[row])"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
