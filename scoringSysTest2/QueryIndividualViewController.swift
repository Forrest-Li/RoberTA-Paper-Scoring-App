//
//  QueryIndividualViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/29.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class QueryIndividualViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var img_photo: UIImageView!
    @IBOutlet weak var tbl_studentAnswers: UITableView!
    
    //MARK: Variables
    var photo: UIImage = UIImage()
    var name: String = ""
    var score: Float = 0
    var studentAnswers: [String] = []
    var answers: [String] = [] //Standard answers
    
    var results: [String] = []
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height

    var activeField: UITextField?
    
    //MARK: override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_studentAnswers.dataSource = self
        tbl_studentAnswers.delegate = self
        
        results = generateResults(answers: answers, studentAnswers: studentAnswers)
        
        addPhoto(photo: photo, imageView: img_photo)
        
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        img_photo.addGestureRecognizer(pictureTap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is QueryInspectViewController {
            
            let vc = segue.destination as? QueryInspectViewController
            
            vc?.modifiedAnswers = [[name], studentAnswers] //WARNING: Cannot handle if one student have two exam answers; need extra considerations
        }
    }
    
    //MARK: Actions
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

    
    //MARK: Utils
    func generateResults(answers: [String], studentAnswers: [String]) -> [String] {
        var tempResults: [String] = []
        for i in 0...(answers.count-1) {
            if answers[i] == studentAnswers[i] {
                tempResults.append("正確")
            }
            else {
                tempResults.append(answers[i])
            }
        }
        return tempResults
    }
    
    /*
     NO NEED for it;
     Reduced image resolution resulted
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        // Fit image with protected fixed width/height ratio in target frame size
        
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }*/
    
    func addPhoto(photo: UIImage, imageView: UIImageView) {
        imageView.image = photo//NO NEED for it: ResizeImage(photo, targetSize: CGSize(width: screenWidth, height: 300))
        imageView.backgroundColor = UIColor(rgb: 0xbdcbff)
        imageView.contentMode =  .scaleAspectFit
        //imageView.frame = CGRect(x: screenWidth/2-250, y: -225, width: 500, height: 525)
        
        //view.addSubview(imgBGImage)
    }
}

extension QueryIndividualViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bgColorView = UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! IndividualStudentTableViewCell
        
        cell.setScore(answer: [String(indexPath.row + 1), studentAnswers[indexPath.row], results[indexPath.row]])
        
        bgColorView.backgroundColor = UIColor(rgb: 0x8b9ae0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: IndividualStudentTableViewCell = tableView.cellForRow(at: indexPath) as! IndividualStudentTableViewCell
        
        studentAnswers[indexPath.row] = cell.returnModifiedValue()
    }
}

//MARK: UIStackView
/*
func initStackView(stackView: UIStackView) {
    // Create view
    stackView.axis = .horizontal
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    
    // Autolayout the stack view - pin 0 up 0 left 0 right 0 down
    let viewsDictionary = ["stackView": stackView]
    let stackView_H = NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-0-[stackView]-0-|",  //horizontal constraint 0 points from left and right side
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: viewsDictionary)
    let stackView_V = NSLayoutConstraint.constraints(
        withVisualFormat: "V:|-0-[stackView]-0-|", //vertical constraint 0 points from top and bottom
        options: NSLayoutConstraint.FormatOptions(rawValue:0),
        metrics: nil,
        views: viewsDictionary)
    
    view.addConstraints(stackView_H)
    view.addConstraints(stackView_V)
}
*/

//MARK: UIImageView
/*
func creatImageView(inStackView: UIStackView, imageView: UIImageView) {
    imageViewkmkkioooko.image = ResizeImage(UIImage(), targetSize: CGSize(width: 500, height: 500))
}
 */
