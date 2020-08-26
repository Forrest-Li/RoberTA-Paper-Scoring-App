//
//  ExamAnswers.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/8/2.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import Foundation
import UIKit

class ExamAnswers{
    var exam: String
    var answers: [String]
    
    init(exam: String, answers: [String]) {
        self.exam = exam
        self.answers = answers
    }
}
