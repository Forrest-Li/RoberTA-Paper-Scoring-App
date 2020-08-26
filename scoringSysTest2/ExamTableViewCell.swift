//
//  ExamTableViewCell.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/27.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class ExamTableViewCell: UITableViewCell {
    @IBOutlet weak var lbl_examName: UILabel!
    @IBOutlet weak var lbl_className: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setScore(examClassPair: [String]) {
        lbl_examName.text = examClassPair[0]
        lbl_className.text = "\(examClassPair[1])年級 \(examClassPair[2])班"
    }
}
