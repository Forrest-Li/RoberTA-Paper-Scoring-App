//
//  QueryViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/25.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit

class QueryViewController: UIViewController {
    
    
    //MARK: Properties
    @IBOutlet weak var tbl_examList: UITableView!
    
    //MARK: Variables
    var examChosen: String = ""
    var scoresList: [StudentSCores] = []
    var sentScoresList: [StudentSCores] = []
    var examList: [[String]] = []
    var answerList: [ExamAnswers] = []
    var sentAnswer: [String] = []
    
    var tempExam: [String] = []

    
    //MARK: override func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Modify the navigation controller
        self.navigationController?.navigationBar.tintColor = UIColor.white//UIColor(rgb: 0x5a6cae)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.alpha = 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_examList.dataSource = self
        tbl_examList.delegate = self

        examList = extractExamList(scoresList: scoresList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is UITabBarController {
            if let vc_parent = segue.destination as? UITabBarController {
                vc_parent.viewControllers?.forEach {
                    if let vc_child = $0 as? QueryInspectViewController {
                        vc_child.scores = self.sentScoresList
                        vc_child.answers = self.sentAnswer
                    }
                    else if let vc_child = $0 as? QueryStatsViewController {
                        vc_child.scores = self.sentScoresList
                        vc_child.answers = self.sentAnswer
                    }
                    else {}
                }
            }
        }
    }
    
    //MARK: Utils
    func extractExamList(scoresList: [StudentSCores]) -> [[String]]{
        //Extract all [Exam Names, Grades, Classes] pairs
        for score in scoresList {
            tempExam = [score.exam, score.grades, String(score.classes)]
            if examList.isEmpty {
                examList.append(tempExam)
            }
            else {
                for exam in examList {
                    if exam != tempExam { examList.append(exam) }
                }
            }
        }
        return examList
    }
}

extension QueryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return examList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bgColorView = UIView()
        let exam = examList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "queryCell", for: indexPath) as! ExamTableViewCell
        
        cell.setScore(examClassPair: exam)
        
        bgColorView.backgroundColor = UIColor(rgb: 0x8b9ae0)
        cell.selectedBackgroundView = bgColorView

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Select from all scores and set sentScoresList
        let exam = examList[indexPath.row]
        for score in scoresList {
            if [score.exam, score.grades, String(score.classes)] == exam {
                sentScoresList.append(score)
            }
        }
        for answer in answerList {
            if answer.exam == exam[0] {
                sentAnswer = answer.answers
            }
        }
        self.performSegue(withIdentifier: "segueFromQueryToMore", sender: self)
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btn_dropExamName.setTitle("\(examList[indexPath.row])", for: .normal)
        animate(toogle: false, type: btn_dropExamName)
        
        examChosen = examList[indexPath.row]
    }
     */
    
}

