//
//  QueryInspectViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/27.
//  Copyright © 2020 Forrest Li. All rights reserved.
//
// WARNING: 修改 button hidden due to infunctionality

import UIKit

class QueryInspectViewController: UIViewController {
    
    //MARK: Variables
    var number = 0
    var answers: [String] = [] //Standard answers
    var scores: [StudentSCores] = []
    //SelectedCOlor = 8b9ae0
    var sentPhoto: UIImage = UIImage() //On click sent student's photo
    var sentName: String = "" //On click sent student's name
    var sentAnswers: [String] = [] //On click sent student's answers
    
    var saveNameBase: String = "Image_"
    var studentNumber: Int = 5
    
    var modifiedAnswers: [[String]] = []
    
    //MARK: Properties
    @IBOutlet weak var lbl_info: UILabel!
    @IBOutlet weak var tbl_studentScores: UITableView!
    
    //MARK: override func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.navigationItem.title = "Bookmarks"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_studentScores.delegate = self
        tbl_studentScores.dataSource = self
        
        for i in 1...(studentNumber) {
            scores[i-1].image = UIImage(named: "IMG_140\(i-1)")!//loadImageFromDiskWith(fileName: "\(saveNameBase)\(i)")!
        }
        
        lbl_info.text = "  當前考試：\(scores[0].exam)\n  當前班級：\(scores[0].grades)年級 \(scores[0].classes)班"
        
        //scores = createArray(number: number)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is QueryIndividualViewController {
            
            let vc = segue.destination as? QueryIndividualViewController
            
            vc?.photo = sentPhoto
            vc?.name = sentName
            vc?.studentAnswers = sentAnswers
            vc?.answers = answers
        }
        else if segue.source is QueryIndividualViewController {
            //WARNING: Cannot handle if one student have two exam answers; need extra considerations
            for i in 0...(scores.count-1) {
                if scores[i].name == modifiedAnswers[0][0] {
                    scores[i].qs = modifiedAnswers[1]
                }
            }
        }
    }
    
    //MARK: Utils
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
              return image
        }
        return nil
    }
    
    /*
    func createArray(number: Int) -> [StudentSCores] {
        var tempScores: [StudentSCores] = []
        let student1 = StudentSCores(image: UIImage(named: "IMG_0020")!, id: 1, name: "李冠杰", score: 80)
        let student2 = StudentSCores(image: UIImage(named: "IMG_0021")!, id: 1, name: "楊大維", score: 80)
        let student3 = StudentSCores(image: UIImage(named: "IMG_0022")!, id: 1, name: "王瀅瑄", score: 80)
        
        tempScores.append(student1)
        tempScores.append(student2)
        tempScores.append(student3)
        
        return tempScores
        /*
        for i in 1...number {
            let student = StudentSCores(image: <#T##UIImage#>, id: <#T##Int#>, name: <#T##String#>, score: <#T##Float#>)
        }
         */
    }*/
}

extension QueryInspectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bgColorView = UIView()
        let score = scores[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoresCell", for: indexPath) as! StudentScoreTableViewCell
        
        cell.setScore(score: score)
        
        bgColorView.backgroundColor = UIColor(rgb: 0x8b9ae0)
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let score = scores[indexPath.row]
        
        sentName = score.name
        sentPhoto = score.image
        sentAnswers = score.qs
        
        self.performSegue(withIdentifier: "segueFromInspectToIndividual", sender: self)
    }
    
    
}
