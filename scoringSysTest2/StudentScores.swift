//
//  StudentScores.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/27.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import Foundation
import UIKit

class StudentSCores{
    var exam: String
    //var examId: Int
    
    var image: UIImage
    var id: Int
    var name: String
    var classes: Int
    var grades: String
    var score: Float
    
    var qs: [String]
    
    /*
    var q1: String
    var q2: String
    var q3: String
    var q4: String
    var q5: String
    var q6: String
    var q7: String
    var q8: String
    var q9: String
    var q10: String
    
    var q11: String
    var q12: String
    var q13: String
    var q14: String
    var q15: String
    var q16: String
    var q17: String
    var q18: String
    var q19: String
    var q20: String
    var q21: String
    var q22: String
    var q23: String
    var q24: String
    var q25: String
     */
    
    init(exam: String, image: UIImage, id: Int, name: String, classes: Int, grades: String, score: Float, qs: [String]) {
        /*,
         q1: String, q2: String, q3: String, q4: String, q5: String,
         q6: String, q7: String, q8: String, q9: String, q10: String,
         q11: String, q12: String, q13: String, q14: String, q15: String,
         q16: String, q17: String, q18: String, q19: String, q20: String,
         q21: String, q22: String, q23: String, q24: String, q25: String) {*/
        self.exam = exam
        //self.examId = examId
        
        self.image = image
        self.id = id
        self.name = name
        self.classes = classes
        self.grades = grades
        self.score = score
        self.qs = qs
        
        /*
        self.q1 = q1
        self.q2 = q2
        self.q3 = q3
        self.q4 = q4
        self.q5 = q5
        self.q6 = q6
        self.q7 = q7
        self.q8 = q8
        self.q9 = q9
        self.q10 = q10
        
        self.q11 = q11
        self.q12 = q12
        self.q13 = q13
        self.q14 = q14
        self.q15 = q15
        self.q16 = q6
        self.q17 = q17
        self.q18 = q18
        self.q19 = q19
        self.q20 = q20
        self.q21 = q21
        self.q22 = q22
        self.q23 = q23
        self.q24 = q24
        self.q25 = q25
         */
    }
}
