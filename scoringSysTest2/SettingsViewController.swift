//
//  SettingsViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/25.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit
//import os.log

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var btn_chooseExam: UIButton!
    @IBOutlet weak var tbl_examList: UITableView!
    @IBOutlet weak var btn_chooseGrades: UIButton!
    @IBOutlet weak var tbl_gradesList: UITableView!
    @IBOutlet weak var btn_chooseClass: UIButton!
    @IBOutlet weak var tbl_classesList: UITableView!
    @IBOutlet weak var txt_studentNumber: UITextField!
    
    @IBOutlet weak var txt_newName: UITextField!
    @IBOutlet weak var btn_confirmNewName: UIButton!
    
    //MARK: Variables
    var examList: [String] = []
    var gradesList: [String] = []
    var classesList: [Int] = []
    var examRowSelected: Int = -1
    var gradesRowSelected: Int = -1
    var classesRowSelected: Int = -1
    var studentNumber: Int = 0
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    //MARK: Components
    let imgBGImage: UIImageView = UIImageView()

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
        
        //Set initial values if already set before
        if examRowSelected != -1 {
            tableView(tbl_examList, didSelectRowAt: IndexPath(row: examRowSelected, section: 0))
        }
        if gradesRowSelected != -1 {
            tableView(tbl_gradesList, didSelectRowAt: IndexPath(row: gradesRowSelected, section: 0))
        }
        if classesRowSelected != -1 {
            tableView(tbl_classesList, didSelectRowAt: IndexPath(row: classesRowSelected, section: 0))
        }
        if studentNumber != 0 {
            txt_studentNumber.text = String(studentNumber)
        }
        
        tbl_examList.isHidden = true
        tbl_gradesList.isHidden = true
        tbl_classesList.isHidden = true
        
        txt_newName.isHidden = true
        btn_confirmNewName.isHidden = true
        // Handle the text field’s user input through delegate callbacks.
        txt_newName.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Remove image to avoid ugly transition
        imgBGImage.image = UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            // return value if already selected some item
            vc?.examRowSelected = examRowSelected
            vc?.gradesRowSelected = gradesRowSelected
            vc?.classesRowSelected = classesRowSelected
            vc?.studentNumber = Int(txt_studentNumber.text!) ?? 0
            vc?.examList = examList
        }
        /*
        else if segue.source is SettingsViewController {
            guard let button = sender as? UIBarButtonItem, button === btn_confirmSettings else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
        }*/
        else{}
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Actions
    @IBAction func onClickDropButton(_ sender: Any) {
        if tbl_examList.isHidden {
            animate(toogle: true, type: btn_chooseExam)
        } else {
            animate(toogle: false, type: btn_chooseExam)
        }
    }
    @IBAction func onClickDropGrades(_ sender: Any) {
        if tbl_gradesList.isHidden {
            animate(toogle: true, type: btn_chooseGrades)
        } else {
            animate(toogle: false, type: btn_chooseGrades)
        }
    }
    @IBAction func onClickDropClasses(_ sender: Any) {
        if tbl_classesList.isHidden {
            animate(toogle: true, type: btn_chooseClass)
        } else {
            animate(toogle: false, type: btn_chooseClass)
        }
    }
    @IBAction func onClickConfirmNewName(_ sender: Any) {
        if txt_newName.text!.isEmpty {
            let alertController = UIAlertController(title: "警告", message:
                "請輸入新考試名字！", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確認", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            examRowSelected += 1 //New entry inserted, so examRowSelected += 1
            examList.insert(txt_newName.text!, at: 1)
            tbl_examList.reloadData()
            tableView(tbl_examList, didSelectRowAt: IndexPath(row: 1, section: 0))
        }
    }
    @IBAction func onClickUnwindToHome(_ sender: Any) {
        if (examRowSelected != -1) && (gradesRowSelected != -1) && (classesRowSelected != -1) && (!txt_studentNumber.text!.isEmpty) {
            performSegue(withIdentifier: "unwindFromSettingsToHome", sender: self)
        }
        else {
            let controller = UIAlertController(title: "警告", message: "請設定完所有參數！", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "確認", style: .default))
            self.present(controller, animated: true, completion: nil)
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
        image.frame = CGRect(x: screenWidth/2-250, y: -225, width: 500, height: 525)
        
        view.addSubview(imgBGImage)
    }
    
    //MARK: Utils
    func animate(toogle: Bool, type: UIButton) {
        
        if type == btn_chooseExam {
        
            if toogle {
                UIView.animate(withDuration: 0.2) {
                    self.tbl_examList.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.tbl_examList.isHidden = true
                }
            }
        }
        else if type == btn_chooseGrades  {
            if toogle {
                UIView.animate(withDuration: 0.2) {
                    self.tbl_gradesList.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.tbl_gradesList.isHidden = true
                }
            }
        }
        else if type == btn_chooseClass {
            if toogle {
                UIView.animate(withDuration: 0.2) {
                    self.tbl_classesList.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.tbl_classesList.isHidden = true
                }
            }
        }
        else {}
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbl_examList {
            return examList.count
        }
        else if tableView == tbl_gradesList {
            return gradesList.count
        }
        else {
            return classesList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tbl_examList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = examList[indexPath.row]
            return cell
        }
        else if tableView == tbl_gradesList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "gradesCell", for: indexPath)
            cell.textLabel?.text = gradesList[indexPath.row]
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "classesCell", for: indexPath)
            cell.textLabel?.text = String(classesList[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tbl_examList {
            btn_chooseExam.setTitle("\(examList[indexPath.row])", for: .normal)
            animate(toogle: false, type: btn_chooseExam)
            
            //examRowSelected = examList[indexPath.row]
            examRowSelected = indexPath.row //Remember current selected item
            if indexPath.row == 0 {
                txt_newName.isHidden = false
                btn_confirmNewName.isHidden = false
            } else{
                txt_newName.isHidden = true
                btn_confirmNewName.isHidden = true
            }
        }
        else if tableView == tbl_gradesList {
            btn_chooseGrades.setTitle("\(gradesList[indexPath.row])", for: .normal)
            animate(toogle: false, type: btn_chooseGrades)
            
            gradesRowSelected = indexPath.row //Remember current selected item
        }
        else {
            btn_chooseClass.setTitle("\(classesList[indexPath.row])", for: .normal)
            animate(toogle: false, type: btn_chooseClass)
            
            classesRowSelected = indexPath.row //Remember current selected item
        }
        
    }
    
}
