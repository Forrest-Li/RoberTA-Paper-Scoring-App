//
//  StatsTableViewCell.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/8/4.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lbl_questionNumber: UILabel!
    @IBOutlet weak var lbl_correctRate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(number: Int, correctRate: Float) {
        lbl_questionNumber.text = String(number)
        if correctRate <= 60.0 {
            lbl_correctRate.textColor = UIColor.red
        } else {
            lbl_correctRate.textColor = UIColor(rgb: 0x006400)
        }
        lbl_correctRate.text = "\(correctRate)%"
    }

}
