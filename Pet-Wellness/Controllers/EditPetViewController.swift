//
//  EditPetViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/8/22.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftUI

class EditPetViewController: UIViewController {
    
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
    var documentID: String = ""
    var speciesName: String = ""
    var sexSelection: String = ""
    
    var inputName: String = ""
    var inputSex: String = ""
    var inputSpecies: String = ""
    var inputBirthday: String = ""
    var inputMicrochip: String = ""
    var inputRabies: String = ""
    var inputProfilePhoto: String = ""
    var inputWeight: String = ""
    var petID: String = ""
    
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
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
        
        setData()
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
    
    func setData() {
        setProfilePhoto()
        setDatePicker()
        
        nameTextField.text = inputName
        weightTextField.text = inputWeight
        microchipTextField.text = inputMicrochip
        rabiesTextField.text = inputRabies
        
        if let index = sexData.firstIndex(of: inputSex) {
            sexPicker.selectRow(index, inComponent: 0, animated: true)
        }
        
        if let index = speciesData.firstIndex(of: inputSpecies) {
            speciesPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func setDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMMM-dd"
        let formattedInputDate = formatter.date(from: inputBirthday)
        datePicker.date = formattedInputDate!
    }
    
    func setProfilePhoto() {
        let url = inputProfilePhoto
        UserDefaults.standard.set(url, forKey: "url")
        
        let finalURL = URL(string: url)
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
    }
    
    
    
    @IBAction func editPetPressed(_ sender: UIButton) {
        if nameTextField.text != "" {
            db.collection(Auth.auth().currentUser!.uid).document(documentID).updateData([
                "description": "petProfile",
                "photo": UserDefaults.standard.object(forKey: "url") ?? "",
                "name": nameTextField.text!,
                "species": speciesName,
                "sex": sexSelection,
                "birthday": getDate(),
                "weight": weightTextField.text!,
                "microchip": microchipTextField.text!,
                "rabies": rabiesTextField.text!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.performSegue(withIdentifier: "EditPetToDashboard", sender: self)
                }
            }
        } else {
            displayAlert(title: "Error", message: "Please add a name, species, and sex")
        }
    }
    
    func displayAlert(title: String, message: String) {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        
        dialogMessage.addAction(ok)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func getDate() -> String {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMMM-dd"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        return selectedDate
    }
}



// MARK: - UIImagePickerControllerDelegate

extension EditPetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension EditPetViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
