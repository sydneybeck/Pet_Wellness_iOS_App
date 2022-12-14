//
//  RemindersCellTableViewCell.swift
//  Pet-Wellness
//
//  Created by sydney beck on 12/7/22.
//

import UIKit

class RemindersCell: UITableViewCell {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate:EditReminderCellDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editButton.layer.cornerRadius = editButton.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.delegate?.goToEditReminder(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
}
