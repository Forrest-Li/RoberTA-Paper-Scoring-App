//
//  StudentScoreTableViewCell.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/27.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class StudentScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl_id: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_score: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setScore(score: StudentSCores) {
        lbl_id.text = String(score.id)
        lbl_name.text = score.name
        lbl_score.text = String(score.score)
    }

}
