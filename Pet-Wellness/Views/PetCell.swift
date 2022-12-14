//
//  NewPetCell.swift
//  Pet-Wellness
//
//  Created by sydney beck on 11/14/22.
//

import UIKit

class PetCell: UITableViewCell {
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var medicationsButton: UIButton!
    @IBOutlet weak var editPetButton: UIButton!
    
    var delegate:GoToPetProfileCellDelegator!
    var delegate2:GoToEditPetCellDelegator!
    
    var callback : ((UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        petImage.layer.cornerRadius = petImage.frame.size.height / 2
        medicationsButton.layer.cornerRadius = medicationsButton.frame.size.height / 5
        editPetButton.layer.cornerRadius = editPetButton.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
        self.delegate2 = nil
    }
    
    @IBAction func dashboardButtonPressed(_ sender: UIButton){
        self.delegate?.goToPetProfile(cell: self)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.delegate2?.goToEditPet(cell: self)
        print("IB editButtonPressed")
    }
    
}
