//
//  QueryStatsViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/27.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit
import Charts

class QueryStatsViewController: UIViewController, ChartViewDelegate {
    
    //MARK: Variables
    var numberList: [Int] = []
    var correctRateList: [Float] = []
    
    //MARK: Properties
    @IBOutlet weak var tbl_questions: UITableView!
    
    //MARK: Variables
    var answers: [String] = [] //Standard answers
    var scores: [StudentSCores] = []
    
    lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = UIColor(rgb: 0xbdcbff)
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tbl_questions.dataSource = self
        self.tbl_questions.delegate = self
        
        //Layout pieChartView constraints
        pieChartView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pieChartView)
        let constraints = [
            pieChartView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            pieChartView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            pieChartView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: 0),
            pieChartView.heightAnchor.constraint(equalToConstant: CGFloat(300))
        ]
        view.addConstraints(constraints)
        
        let labels = ["0_60", "60_70", "70_80", "80_90", "90_100"]
        let distribution = [10, 12, 22, 34, 5]
        
        setChart(dataLabels: labels, values: distribution)
        
        numberList = Array(1...25)
        correctRateList = [95.0, 93.3, 87.7, 60.0, 66.6,
                           75.0, 80.0, 90.0, 70.0, 85.0,
                           66.6, 75.0, 88.0, 93.3, 95.0,
                           85.0, 80.0, 85.0, 50.0, 77.7,
                           85.0, 90.0, 83.3, 78.8, 50.0
        ]
    }
    
    func setChart(dataLabels: [String], values: [Int]) {
        var dataEntries: [ChartDataEntry] = []
        
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = dataLabels[index]
            dataEntries.append( entry)
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "成績分布")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        pieChartView.data = pieChartData

        let colors: [UIColor] = [
            UIColor(rgb: 0x8B9AE0),
            UIColor(rgb: 0x7480E5),
            UIColor(rgb: 0x5D67EA),
            UIColor(rgb: 0x464D80),
            UIColor(rgb: 0x3400EE)
        ]

        pieChartDataSet.colors = colors
    }
    
}

extension QueryStatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bgColorView = UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! StatsTableViewCell
        cell.setCell(number: numberList[indexPath.row], correctRate: correctRateList[indexPath.row])
        
        bgColorView.backgroundColor = UIColor(rgb: 0x8b9ae0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    
}
