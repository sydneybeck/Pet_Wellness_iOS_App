//
//  MedicationsCell.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/5/22.
//

import UIKit

class MedicationsCell: UITableViewCell {
    

    @IBOutlet weak var medicationNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var delegate:EditMedicationsCellDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editButton.layer.cornerRadius = editButton.frame.size.height / 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.delegate?.goToEditMedication(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
}
