//
//  ViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/18.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Variables
    var examList: [String] = ["新增考試名稱",
                              "第二次數學科第四次月考",
                              "第二次數學科第三次月考",
                              "第二次數學科第二次月考",
                              "第二次數學科第一次月考"]
    var gradesList: [String] = ["一", "二", "三", "四", "五", "六"]
    var classesList: [Int] = Array(1...10)
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    var completeExamList: Array = ["第二次數學科第三次月考"]
    
    var examRowSelected: Int = -1
    var classesRowSelected: Int = -1
    var gradesRowSelected: Int = -1
    var studentNumber: Int = 0
    
    var detectedTextAnswer: String = ""
    
    var builtInScores: [StudentSCores] = []
    var builtInAnswers: [ExamAnswers] = []
    
    //MARK: Components
    let imgBGImage: UIImageView = UIImageView()
    
    //MARK: override func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Initialize image
        addBGImage(image: imgBGImage)
        view.sendSubviewToBack(imgBGImage)
        
        // Reset the navigation controller
        self.navigationController?.navigationBar.tintColor = UIColor.white//UIColor(rgb: 0x5a6cae)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.alpha = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cancel Initialize image to viewWillAppear
        //addBGImage(image: imgBGImage)
        //view.sendSubviewToBack(imgBGImage)
        
        // Create built-in data
        builtInScores = createStudentScores()
        builtInAnswers = createExamAnswers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Remove image to avoid ugly transition
        imgBGImage.image = UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is SettingsViewController {
            let vc = segue.destination as? SettingsViewController
            // return value if already selected some item
            if examRowSelected != -1 {
                vc?.examRowSelected = examRowSelected
            }
            if gradesRowSelected != -1 {
                vc?.gradesRowSelected = gradesRowSelected
            }
            if classesRowSelected != -1 {
                vc?.classesRowSelected = classesRowSelected
            }
            if studentNumber != 0 {
                vc?.studentNumber = studentNumber
            }
            vc?.examList = examList
            vc?.gradesList = gradesList
            vc?.classesList = classesList
        }
        else if segue.destination is ImportViewController {
            let vc = segue.destination as? ImportViewController
            vc?.examChosen = examList[examRowSelected]
            vc?.classes = classesList[classesRowSelected]
            vc?.grades = gradesList[gradesRowSelected]
            vc?.studentNumber = studentNumber
        }
        else if segue.destination is ScoringViewController {
            let vc = segue.destination as? ScoringViewController
            vc?.studentNumber = studentNumber
            vc?.examAnswer = detectedTextAnswer
            vc?.scoresList = builtInScores
            vc?.examChosen = examList[examRowSelected]
            vc?.classes = classesList[classesRowSelected]
            vc?.grades = gradesList[gradesRowSelected]
        }
        else if segue.destination is QueryViewController {
            let vc = segue.destination as? QueryViewController
            vc?.scoresList = builtInScores
            vc?.answerList = builtInAnswers
        }
        else {}
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
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
    @IBAction func segueToSettings(_ sender: Any) {
        performSegue(withIdentifier: "segueFromHomeToSettings", sender: self)
    }
    @IBAction func segueToImport(_ sender: Any) {
        
        if examRowSelected == -1 && studentNumber == 0 {
            // Alert when 參數設定 not completed
            let alertController = UIAlertController(title: "警告", message:
                "請先設定參數再匯入答案！", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            // 參數設定 completed: 匯入答案
            performSegue(withIdentifier: "segueFromHomeToImport", sender: self)
        }
    }
    @IBAction func segueToStart(_ sender: Any) {

        if detectedTextAnswer.isEmpty {
            // Alert when 匯入答案 not completed
            let alertController = UIAlertController(title: "警告", message:
                "請先匯入答案再開始批閱！", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: {
                ACTION in
                if self.examRowSelected == -1 && self.studentNumber == 0 {
                    // Alert when 參數設定 not completed
                    let alertController2 = UIAlertController(title: "警告", message:
                        "請先設定參數再匯入答案！", preferredStyle: .alert)
                    alertController2.addAction(UIAlertAction(title: "取消", style: .default))
                    self.present(alertController2, animated: true, completion: nil)
                } else {
                    // 參數設定 completed: 匯入答案
                    self.performSegue(withIdentifier: "segueFromHomeToImport", sender: self)
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            // 匯入答案 completed: 開始批閱
            performSegue(withIdentifier: "segueFromHomeToStart", sender: self)
        }
    }
    @IBAction func segueToQuery(_ sender: Any) {
        performSegue(withIdentifier: "segueFromHomeToQuery", sender: self)
    }
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
    @IBAction func onClickImportAnswer(_ sender: Any) {
        
        /*if let unwrapExamChosen = examChosen { // to unwrap the optional value
          // check textfield is not nil
            lbl_currExam.text = unwrapExamChosen
        }
        else {
            lbl_currExam.text = "null"
        }
        
        if let unwrapGrades = grades, let unwrapClasses = classes {
            lbl_currClassName.text = "\(unwrapGrades)年 \(unwrapClasses)班"
        }
        else {
            lbl_currClassName.text = "0年 0班"
        }*/
        
    }
    
    //MARK: Built_in data
    func createExamAnswers() -> [ExamAnswers] {
        var tempAnswers: [ExamAnswers] = []
        
        let tempAnswersList: [[String]] = [["A", "B", "A", "C", "E", "D", "D", "B", "E", "C",
        "46", "8", "55", "2", "0", "0", "40", "17", "28", "66", "1", "75", "35", "20", "0"],]
        let tempExamsList: [String] = ["第二次數學科第三次月考"]
        
        for i in 0...0 {
            let answer = ExamAnswers(exam: tempExamsList[i], answers: tempAnswersList[i])
            tempAnswers.append(answer)
        }
        
        return tempAnswers
    }
    
    func createStudentScores() -> [StudentSCores] {
        /*
        let student1 = StudentSCores(image: UIImage(named: "IMG_0020")!, id: 1, name: "李冠杰", score: 80)
        let student2 = StudentSCores(image: UIImage(named: "IMG_0021")!, id: 1, name: "楊大維", score: 80)
        let student3 = StudentSCores(image: UIImage(named: "IMG_0022")!, id: 1, name: "王瀅瑄", score: 80)
        
        tempScores.append(student1)
        tempScores.append(student2)
        tempScores.append(student3)
        
        return tempScores
        */
        
        var tempScores: [StudentSCores] = []
        let tempIdList: [Int] = [1, 2, 3, 4, 5, 10, 3, 15, 22, 13, 12 ,11]
        let tempNameList: [String] = ["高孟謙", "蔡秉修", "蔡昀儒", "楊大維", "何無洋", "施冠彰", "張雨勝", "孟陽"]
        let tempClasses = 1
        let tempGrades = "三"
        let tempScoreList: [Float] = [84, 72, 68, 80, 64]
        let tempAnswerList: [[String]] = [
            ["A", "B", "A", "C", "E", "B", "B", "B", "E", "C",
            "46", "8", "55", "2", "0", "0", "20", "17", "28", "66", "1", "0", "35", "20", "0"],
            ["A", "B", "C", "C", "E", "B", "D", "B", "C", "C",
            "46", "8", "50", "2", "1", "0", "40", "17", "0", "66", "1", "70", "35", "20", "0"],
            ["A", "B", "C", "C", "D", "D", "D", "A", "B", "C",
            "46", "7", "55", "1", "0", "0", "40", "16", "28", "66", "1", "74", "35", "20", "0"],
            ["B", "B", "A", "C", "E", "D", "D", "B", "E", "C",
            "0", "8", "55", "2", "0", "0", "41", "17", "28", "0", "1", "75", "0", "20", "0"],
            ["B", "C", "A", "C", "E", "D", "B", "E", "B", "C",
            "46", "9", "55", "2", "0", "0", "41", "17", "29", "66", "1", "75", "36", "20", "0"],
            ["A", "A", "A", "C", "E", "D", "D", "B", "E", "C",
            "46", "88", "0", "2", "0", "0", "40", "1", "28", "0", "1", "75", "35", "20", "0"],
            ["A", "B", "A", "C", "E", "D", "D", "C", "B", "C",
            "46", "12", "51", "2", "0", "0", "41", "11", "27", "66", "1", "75", "31", "20", "0"]
        ]
        /*
         5 李
         B, B, A, C, E, D, D, B, E, C
         56, 8, 55, 2, 0, 0, 40, 17, 28, 60, 0, 75, 35, 20, 2
         10 大
         A, B, A, B, E, D, C, B, E, C
         46, 8, 55, 2, 0, 1, 20, 17, 28, 66, 1, 75, 36, 25, 0
         3 王
         A, B, A, E, E, D, D, A, E, C
         46, 8, 55, 3, 0, 0, 40, 77, 20, 66, 7, 77, 33, 22, 0
         15 陳
         A, C, C, C, E, B, D, C, A, C
         44, 8, 51, 1, 0, 0, 40, 17, 27, 66, 1, 79, 35, 24, 0
         22, 王
         B, B, A, E, C, A, B, C, E, A
         0, 8, 0, 1, 0, 0, 40, 17, 22, 64, 1, 75, 30, 20, 1
         13 施
         A, B, B, C, E, A, D, B, C, E
         46, 7, 55, 3, 20, 0, 40, 17, 28, 67, 1, 75, 35, 20, 0
         12 張
         A, A, A, C, E, D, D, B, E, C
         46, 88, 0, 2, 0, 0, 40, 1, 28, 0, 1, 75, 35, 20, 0
         11 孟
         A, B, A, C, E, D, D, C, B, C
         46, 12, 51, 2, 0, 0, 41, 11, 27, 66, 1, 75, 31, 20, 0
         */
        
        for i in 0...4 {
            let student = StudentSCores(exam: completeExamList[0],
                                        image: UIImage(named: "IMG_140\(i)")!,
                                        id: tempIdList[i],
                                        name: tempNameList[i],
                                        classes: tempClasses,
                                        grades: tempGrades,
                                        score: tempScoreList[i],
                                        qs: tempAnswerList[i]
            )
            tempScores.append(student)
        }
        
        return tempScores
    }
    
}

//MARK: Modify UIColor init
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

    convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
