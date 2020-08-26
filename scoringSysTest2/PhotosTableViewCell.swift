//
//  PhotosTableViewCell.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/8/4.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class PhotosTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var lbl_id: UILabel!
    @IBOutlet weak var img_photo: UIImageView!
    @IBOutlet weak var lbl_text: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPhoto(id: Int, photo: UIImage, text: String) {
        lbl_id.text = String(id)
        img_photo.image = photo
        //NO NEED, will pop waring, set in storyboard: img_photo.contentMode = .scaleAspectFill
        img_photo.backgroundColor = UIColor(rgb: 0xbdcbff)
        lbl_text.text = text
    }

}
