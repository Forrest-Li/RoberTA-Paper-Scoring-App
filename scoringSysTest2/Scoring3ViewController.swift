//
//  Scoring3ViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/8/4.
//  Copyright © 2020 Forrest Li. All rights reserved.
//
/* StudentScores class
 √          var exam: String
 (need new names) var image: UIImage
 Detected   var id: Int
 Detected   var name: String
 √          var classes: Int
 √          var grades: String
 Evaluated  var score: Float
 Detected   var qs: [String]
 */

import UIKit
import Vision

class Scoring3ViewController: UIViewController {
    
    //MARK: Variables
    var examAnswer: String = ""
    var studentNumber: Int = 0
    var saveNameBase: String = ""
    
    var scoresList: [StudentSCores] = []
    var examChosen: String = ""
    var classes: Int = 0
    var grades: String = ""
    
    var tempDetectedText: String = ""
    var imageList: [UIImage] = []
    var detectedTextList: [String] = []
    
    //MARK: Properties
    @IBOutlet weak var btn_confirm: UIButton!
    
    private let textRecognitionWorkQueue = DispatchQueue(label: "forrestsRecogQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // text recognition variable setting
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]//, "zh_CN"]
        request.usesLanguageCorrection = true
        //request.minimumTextHeight = 0.05
        return request
    }()

    //MARK: Properties
    @IBOutlet weak var tbl_photos: UITableView!
    
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

        self.tbl_photos.dataSource = self
        self.tbl_photos.delegate = self
        
        //tempImage = loadImageFromDiskWith(fileName: "\(saveNameBase)\(indexPath.row)")!
        
        //processImage(image: tempImage)
        
        for i in 1...studentNumber {
            imageList.append(loadImageFromDiskWith(fileName: "\(saveNameBase)\(i)")!)
        }
        for i in 1...studentNumber {
            processImage(image: imageList[i-1])
            
            while tempDetectedText.isEmpty {}
            detectedTextList.append(tempDetectedText)
            tempDetectedText = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.builtInScores = scoresList
        }
    }
    
    //MARK: Actions
    @IBAction func onClickConfirm(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromScoring3ToHome", sender: self)
    }
    
    //MARK: - Utils
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            presentAlert(title: "錯誤", message: error.localizedDescription)
            return
        }
        guard let results = request?.results, results.count > 0 else {
            presentAlert(title: "警告", message: "未偵測到文字！")
            return
        }
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    tempDetectedText = "\(tempDetectedText)\n\(text.string)"
                }
            }
        }
        
        //DispatchQueue.main.async {
            //self.lbl_detectedText.text = self.detectedText
            //self.btn_confirm.isHidden = false
            /*if numberComponent.text.count >= 3 {
                self.numberLabel.text = "\(numberComponent.text.prefix(3))"
            }
            if setComponent.text.count >= 3 {
                self.setLabel.text = "\(setComponent.text.prefix(3))"
            }*/
        //}
        
    }
    
    fileprivate func presentAlert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func processImage(image: UIImage!) {
        tempDetectedText = ""
        //setLabel.text = ""
        //numberLabel.text = ""
        
        guard let image = image, let cgImage = image.cgImage else { return }
        /*
        var orient_normal: Bool = true
        if image.size.height > image.size.width {
            orient_normal = false
        }
         */
        
        let requests = [textDetectionRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        /*
        let imageRequestHandler = { () -> VNImageRequestHandler in
            if orient_normal {
                return VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            } else {
                return VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
            }
        }()
         */
        
        textRecognitionWorkQueue.async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
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
}

extension Scoring3ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bgColorView = UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkDetectCell", for: indexPath) as! PhotosTableViewCell
        cell.setPhoto(id: indexPath.row+1, photo: imageList[indexPath.row], text: detectedTextList[indexPath.row])
        
        bgColorView.backgroundColor = UIColor(rgb: 0x8b9ae0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newImageView = UIImageView(image: imageList[indexPath.row])
        
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
}
