//
//  ScoringViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/25.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class ScoringViewController: UIViewController {
    
    //MARK: Variables
    var intervalChosen: Int = 0
    var studentNumber: Int = 0
    var examAnswer: String = ""
    
    var scoresList: [StudentSCores] = []
    var examChosen: String = ""
    var classes: Int = 0
    var grades: String = ""
    
    var naviHeight: CGFloat? = 0
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    let imgBGImage: UIImageView = UIImageView()
    
    @IBOutlet weak var navi_titleNavigator: UINavigationItem!

    //MARK: override func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Initialize image
        addBGImage(image: imgBGImage)
        view.sendSubviewToBack(imgBGImage)
        
        // Modify the navigation controller
        self.navigationController?.navigationBar.tintColor = UIColor.white//UIColor(rgb: 0x5a6cae)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.alpha = 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviHeight = self.navigationController?.navigationBar.frame.height

        // Cancel Initialize image to viewWillAppear
        //addBGImage(image: imgBGImage)
        //view.sendSubviewToBack(imgBGImage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Remove image to avoid ugly transition
        imgBGImage.image = UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is Scoring2ViewController {
            let vc = segue.destination as? Scoring2ViewController
            vc?.intervalTime = intervalChosen
            vc?.studentNumber = studentNumber
            vc?.examAnswer = examAnswer
            vc?.scoresList = scoresList
            vc?.examChosen = examChosen
            vc?.classes = classes
            vc?.grades = grades
        }
    }
    
    //MARK: UIImage settings
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
    }
    
    func addBGImage(image: UIImageView) {
        image.image = #imageLiteral(resourceName: "home_bg_105_100") //ResizeImage(#imageLiteral(resourceName: "home_bg_105_100"), targetSize: CGSize(width: 500, height: 525))
        
        image.contentMode = .scaleToFill
        image.frame = CGRect(x: screenWidth/2-250, y: -125, width: 500, height: 525)
        
        view.addSubview(imgBGImage)
    }
    
    //MARK: Actions
    @IBAction func onClickInterval5(_ sender: Any) {
        intervalChosen = 5
        
        performSegue(withIdentifier: "segueFromScoringToScoring2", sender: self)
    }
    @IBAction func onClickInterval10(_ sender: Any) {
        intervalChosen = 10
        
        performSegue(withIdentifier: "segueFromScoringToScoring2", sender: self)
    }
}
