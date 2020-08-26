//
//  IndividualStudentTableViewCell.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/29.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class IndividualStudentTableViewCell: UITableViewCell {
    
    var flag: Int = 0

    @IBOutlet weak var lbl_number: UILabel!
    @IBOutlet weak var txt_answer: UITextField!
    @IBOutlet weak var lbl_correct: UILabel!
    @IBOutlet weak var btn_modify: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setScore(answer: [String]) {
        flag = 0
        lbl_number.text = answer[0]
        txt_answer.text = answer[1]
        txt_answer.isEnabled = false
        lbl_correct.text = answer[2]
        if answer[2] == "正確" {
            lbl_correct.textColor = UIColor(rgb: 0x006400)
        } else {
            lbl_correct.textColor = UIColor.red
        }
    }
    
    func returnModifiedValue() -> String {
        return txt_answer.text!//[lbl_number.text!, txt_answer.text!, lbl_correct.text!]
    }
    
    //MARK: Actions
    @IBAction func onClickModify(_ sender: Any) {
        if flag == 0 {
            txt_answer.isEnabled = true
            btn_modify.setTitle("確認", for: .normal)
            flag = 1
        } else {
            txt_answer.isEnabled = false
            btn_modify.setTitle("修改", for: .normal)
            flag = 0
        }
    }
    
}
