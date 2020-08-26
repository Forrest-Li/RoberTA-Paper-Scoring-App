//
//  ImportViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/25.
//  Copyright © 2020 Forrest Li. All rights reserved.
//
/**
 Detection Workflow
 1. Creating textDetectionRequest variable to store text recognition settings
 // using: var textDetectionRequest
 
 2.When either choosePhoto or takePhoto is chosed, presentPhotoPicker func is called to get an image as output
 // using: func choosePhoto, func takePhoto, func presentPhotoPicker
 
 3.Either imagePickerControllerDidCancel func is called due to dismiss selecting photo action or imagePickerController func is called as a result of selecting an image
 // using: func imagePickerControllerDidCancel, func imagePickerController
 
 4. When an image is selected, processImage func is called to process the following actions
 // using: func processImage
 
 5. textDetectionRequest variable forms a request while calling handleDetectedText func to extract text in the image
 // using: var textDetectionRequest, func handleDetectedText
 
 6. In handleDetectedText, VNRecognizeTextRequest forms a request that will return VNRecognizedTextObservation that inherits from VNRectangleObservation which performs both text detection & recognition on the given image.
 */

import UIKit
import Vision
import Photos

class ImportViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var lbl_currExam: UILabel!
    @IBOutlet weak var lbl_currClassName: UILabel!
    @IBOutlet weak var lbl_currNumber: UILabel!
    @IBOutlet weak var scrView_detectedText: UIScrollView!
    @IBOutlet weak var btn_confirm: UIButton!
    @IBOutlet weak var lbl_detectedText: UILabel!
    
    //MARK: Variables
    var examChosen: String = ""
    var grades: String = ""
    var classes: Int = 0
    var studentNumber: Int = 0
    var image: UIImage?
    var detectedAnswer: [[String]] = []
    var detectedText: String = ""
    
    var orientationUpFlag: Bool = true
    
    var all_boxes: [[CGFloat]] = []
    var all_text: [String] = []
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    private let textRecognitionWorkQueue = DispatchQueue(label: "forrestsRecogQueue1", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    //MARK: Components
    let imgBGImage: UIImageView = UIImageView()
    
    // text recognition variable setting
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]//, "zh_CN"]
        request.usesLanguageCorrection = true
        //request.minimumTextHeight = 0.05
        return request
    }()
    
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

        // Do any additional setup after loading the view.
        btn_confirm.isHidden = true
        lbl_currExam.text = examChosen
        lbl_currClassName.text = "\(grades)年級 \(classes)班"
        lbl_currNumber.text = "\(studentNumber)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is ViewController {
            let vc = segue.destination as? ViewController
            vc?.detectedTextAnswer = detectedText
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
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            presentAlert(title: "錯誤", message: error.localizedDescription)
            return
        }
        guard let results = request?.results, results.count > 0 else {
            presentAlert(title: "警告", message: "未偵測到文字！")
            return
        }
        
        /* observation.boundingBox
         The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
         */
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    detectedText = "\(detectedText)\n\(text.string)"
                    all_boxes.append([(observation.boundingBox.minX+observation.boundingBox.maxX)/2,
                                      (observation.boundingBox.minY+observation.boundingBox.maxY)/2,
                                      observation.boundingBox.width,
                                      observation.boundingBox.height])
                    all_text.append(text.string)
                    //detectedText = "\(detectedText)\n\(observation.boundingBox)"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.detectedText = self.processText() + "\n原始偵測結果:" + self.detectedText
            
            self.lbl_detectedText.text = self.detectedText
            self.btn_confirm.isHidden = false
            /*if numberComponent.text.count >= 3 {
                self.numberLabel.text = "\(numberComponent.text.prefix(3))"
            }
            if setComponent.text.count >= 3 {
                self.setLabel.text = "\(setComponent.text.prefix(3))"
            }*/
        }
        
    }
    
    fileprivate func presentAlert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func processImage() {
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
        let imageRequestHandler = { () -> VNImageRequestHandler in
            if orientationUpFlag {
                return VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            } else {
                return VNImageRequestHandler(cgImage: cgImage, orientation: .left, options: [:])
            }
        }()
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
    
    fileprivate func presentPhotoPicker(type: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.sourceType = type
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func processText() -> String {
        var all_y_coords: [Float] = [] //multiplied by 100
        var all_x_coords: [Float] = [] //multiplied by 100
        
        for i in all_boxes {
            all_y_coords.append(100*Float(i[1]))
        }
        for i in all_boxes {
            all_x_coords.append(100*Float(i[0]))
        }
        
        var lineStartIndexes: [Int] = [] //totally 3 start indexes of number lines: 1-10, 1-10, 11-15
        var lineEndIndexes: [Int] = [] //totally 3 end indexes of number lines: 1-10, 1-10, 11-15
        var buffer1 = 0
        var buffer2 = 0

        //Extract start indexes
        for id in 1...(all_y_coords.count-1) {
            if buffer1 > 0 {
                buffer1 -= 1
            }
            else {
                if [1, 2, 3].contains(Int(all_text[id])) {
                    buffer1 = 4
                    lineStartIndexes.append(id)
                }
                else if [11, 12, 13].contains(Int(all_text[id])) {
                    buffer1 = 4
                    lineStartIndexes.append(id)
                }
            }
        }
        if lineStartIndexes.count >= 3 {
            lineStartIndexes = Array(lineStartIndexes[0..<3])
        }else {
            return ""
        }
        
        //Extract end indexes
        for id in stride(from: (all_y_coords.count-1), through: 0, by: -1)  {
            if buffer2 > 0 {
                buffer2 -= 1
            }
            else {
                if [8, 9, 10].contains(Int(all_text[id])) {
                    buffer2 = 4
                    lineEndIndexes.append(id)
                }
                else if [13, 14, 15].contains(Int(all_text[id])) {
                    buffer2 = 4
                    lineEndIndexes.append(id)
                }
            }
        }
        if lineEndIndexes.count >= 3 {
            lineEndIndexes = Array(lineEndIndexes[0..<3])
            lineEndIndexes = lineEndIndexes.reversed()
        }else {
            return ""
        }

        //Extract answers line by line
        for (id, index) in lineEndIndexes.enumerated() { //id: line number; index: line reference index
            //select candidates
            var candidates: [String] = []
            if id != 2 {
                if candidates.count-1 < index+13 {
                    candidates = Array(all_text[(index+1)...])
                } else {
                    candidates = Array(all_text[(index+1)..<(index+13)])
                }
            } else { //last line slicing to tail
                candidates = Array(all_text[(index+1)...])
            }
            var removeIndex: [Int] = []
            
            //filter candidates
            for candidateIndex in 0...(candidates.count-1) {
                if id == 0 {
                    //lineType is character
                    let trim_space = candidates[candidateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !["A", "B", "C", "D", "E"].contains(trim_space){
                        removeIndex.append(candidateIndex)
                    }
                } else if id == 1 {
                    //lineType is number, 1st line; letter o, O is 0
                    let trim_space = candidates[candidateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    if ["O", "o"].contains(trim_space){
                        candidates[candidateIndex] = "0"
                    }
                    if Int(trim_space) == nil || [11, 12, 13, 14, 15].contains(Int(trim_space)) {
                        removeIndex.append(candidateIndex)
                    }
                } else {
                    //lineType is number, 2nd line; letter o, O is 0
                    let trim_space = candidates[candidateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    if ["O", "o"].contains(trim_space){
                        candidates[candidateIndex] = "0"
                    }
                    if Int(trim_space) == nil{
                        removeIndex.append(candidateIndex)
                    }
                }
            }
            
            //Remove wrong predictions
            candidates = Array(candidates
                .enumerated()
                .filter { !removeIndex.contains($0.offset) }
                .map { $0.element })
            detectedAnswer.append(candidates)
        }
        return "\(1...10)\n\(detectedAnswer[0])\n\(1...10)\n\(detectedAnswer[1])\n\(11...15)\n\(detectedAnswer[2])\n"
    }
    
    //MARK: Actions
    @IBAction func choosePhoto(_ sender: Any) {
        all_boxes = []
        all_text = []
        detectedText = ""
        detectedAnswer = []
        
        orientationUpFlag = false
        
        presentPhotoPicker(type: .photoLibrary)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        all_boxes = []
        all_text = []
        detectedText = ""
        detectedAnswer = []
        
        orientationUpFlag = true
        
        presentPhotoPicker(type: .camera)
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromImportToHome", sender: self)
    }
}

extension ImportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        image = info[.originalImage] as? UIImage
        
        processImage()
    }
    
}
