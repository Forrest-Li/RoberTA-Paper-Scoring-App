//
//  Scoring2ViewController.swift
//  scoringSysTest2
//
//  Created by Forrest Li on 2020/7/27.
//  Copyright © 2020 Forrest Li. All rights reserved.
//

import UIKit
import AVFoundation

class Scoring2ViewController: UIViewController {
    
    //MARK: Variables
    var intervalTime: Int = 5
    var studentNumber: Int = 2
    var examAnswer: String = ""
    
    var scoresList: [StudentSCores] = []
    var examChosen: String = ""
    var classes: Int = 0
    var grades: String = ""
    
    var totalTime: Double = 0
    var startTime: Double = 0
    var passedTime: Double = 0
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    var buttonRadius:CGFloat = 0.0
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    let previewSession = AVCaptureSession()
    let captureSession = AVCaptureSession()
    
    let videoQueue = DispatchQueue(label: "VIDEO_QUEUE")
    var initTimeFlag: Int = 0
    var currentTime: Int = 0
    
    var saveCount: Int = 1
    var saveNameBase: String = "Image_"
    
    //MARK: UI components
    //View 1
    let cameraButton: UIButton = UIButton()
    let intervalLabel: UILabel = UILabel()
    let timeLabel: UILabel = UILabel()
    var timer: Timer = Timer()

    let testLabel: UILabel = UILabel()
    
    //View 2
    var safeArea: UILayoutGuide!
    let stackView: UIStackView = UIStackView()
    let examTableView: UITableView = UITableView()
    let confirmButton: UIButton = UIButton()
    
    @IBOutlet weak var navi_titleNavigator: UINavigationItem!
    
    //MARK: override func
    override func loadView() {
      super.loadView()
      //view.backgroundColor = .white
      safeArea = view.layoutMarginsGuide
      //setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Modify the navigation controller
        self.navigationController?.navigationBar.tintColor = UIColor.white//UIColor(rgb: 0x5a6cae)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.alpha = 0.3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalTime = Double(intervalTime * studentNumber)

        let temp: CGFloat = CGFloat(screenWidth/12)
        buttonRadius = { () -> CGFloat in
            if temp > 100 {
                return 100
            } else {
                return temp
            }
        }()
        
        navi_titleNavigator.accessibilityElementsHidden = true
        
        createTimeLabel(label: timeLabel, position_rightTop: true)
        createTimeLabel(label: intervalLabel, position_rightTop: false)
        createCameraButton(button: cameraButton)

        createTestLabel(label: testLabel)
        
        beginPreviewSession()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is Scoring3ViewController {
            let vc = segue.destination as? Scoring3ViewController
            vc?.examAnswer = examAnswer
            vc?.studentNumber = studentNumber
            vc?.saveNameBase = saveNameBase
            vc?.scoresList = scoresList
            vc?.examChosen = examChosen
            vc?.classes = classes
            vc?.grades = grades
        }
    }
    
    //MARK: - Utils
    func removeSubview(tag: Int){
        if let viewWithTag = self.view.viewWithTag(tag) {
            viewWithTag.removeFromSuperview()
            print("Removed view with tag \(tag).")
        }else{
            print("Unable to remove view with tag \(tag)!")
        }
    }
    
    func convert(cmage: CIImage) -> UIImage {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
    func writeImage(imageName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }

        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
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
    
    //MARK: - UIButton settings
    @objc func onClickCameraButton(_ sender: UIButton) {
        self.cameraButton.isEnabled = false
            
        //Stop preview session and view
        previewSession.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
        
        //Run capture session and view
        beginSession()
        captureSession.startRunning()
        
        cameraButton.backgroundColor = UIColor.red
        cameraButton.alpha = 0.5

        //Start timer
        startTime = NSDate().timeIntervalSince1970 //in sec.
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.labelUpdate), userInfo: nil, repeats: true)
    
    }
    
    func createCameraButton(button: UIButton) {
        button.frame = CGRect(x: screenWidth*0.5-buttonRadius, y: screenHeight*0.9-buttonRadius, width: buttonRadius*2, height: buttonRadius*2)
        //button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.tag = 104
        button.addTarget(self, action: #selector(onClickCameraButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    //MARK: - UILabel settings
    @objc func labelUpdate() {
        passedTime = NSDate().timeIntervalSince1970 - startTime
        self.timeLabel.text = "剩餘時間: \(Int(totalTime-passedTime))秒  "
        
        //If Time up
        if passedTime >= totalTime {
            timer.invalidate()
            captureSession.stopRunning()
            
            let alertController = UIAlertController(title: "通知", message:
                "試卷批閱完成！", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確認", style: .default, handler: {
                ACTION in
                do{
                    self.removeSubview(tag: 100)
                    self.removeSubview(tag: 101)
                    self.removeSubview(tag: 102)
                    self.removeSubview(tag: 103)
                    self.removeSubview(tag: 104)
                    self.removeSubview(tag: 999)
                    self.previewLayer?.removeFromSuperlayer()
                    self.performSegue(withIdentifier: "segueFromScoring2ToScoring3", sender: self)
                }//self.performSegue(withIdentifier: "unwindFromScoring2ToHome", sender: self)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    
    func createTimeLabel(label: UILabel, position_rightTop: Bool) {
        if position_rightTop {
            label.frame = CGRect(x: screenWidth/2, y: screenHeight-30, width: screenWidth/2, height: 30)
            //label.alpha = 0
            label.text = "剩餘時間: \(Int(totalTime))秒"
            label.font = .systemFont(ofSize: 17)
            label.textColor = UIColor.yellow
            label.textAlignment = .right
            label.tag = 100
        }
        else {
            label.frame = CGRect(x: 0, y: screenHeight-30, width: screenWidth/2, height: 30)
            //label.alpha = 0
            label.text = "  時間間隔: \(intervalTime)秒"
            label.font = .systemFont(ofSize: 17)
            label.textColor = UIColor.yellow
            label.textAlignment = .left
            label.tag = 101
        }
        self.view.addSubview(label)
    }
    
    func createTestLabel(label: UILabel){
        label.frame = CGRect(x: 0, y: screenHeight-60, width: screenWidth, height: 30)
        //label.alpha = 0
        label.text = ""//"TEST TEXT"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor.yellow
        label.textAlignment = .left
        label.tag = 999
        
        self.view.addSubview(label)
    }
    
    //MARK: - AVCaptureSession previewSession settings
    func beginPreviewSession() {
        // Prevent pre-running or previous running
        if previewSession.isRunning {
            previewSession.stopRunning()
        }
        self.previewLayer?.removeFromSuperlayer()
        
        previewSession.sessionPreset = AVCaptureSession.Preset.iFrame960x540
        
        // Guard permissions of camera
        switch (AVCaptureDevice.authorizationStatus(for: .video)) {
          case .denied:
            print("Denied access to \(AVMediaType.video.rawValue)")
            break
          case .authorized:
            print("Granted access to \(AVMediaType.video.rawValue)")
            break
          case .restricted:
            print("Restricted access to \(AVMediaType.video.rawValue)")
            break
          case .notDetermined:
            print("Access to \(AVMediaType.video.rawValue) is not Determined.\n")
            AVCaptureDevice.requestAccess(for: .video, completionHandler:{ granted in
              print("Checking access to \(AVMediaType.video.rawValue)")
                if granted {
                  print("Granted access to \(AVMediaType.video.rawValue)")
                } else {
                  print("Denied access to \(AVMediaType.video.rawValue)")
                }
            })
            break
        }
        do {
            // Add InputDevice
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)//devices()
            guard
                let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice!),
                previewSession.canAddInput(videoDeviceInput)
                else { return }
            previewSession.addInput(videoDeviceInput)
        }
        
        // Add PreviewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: previewSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        // Add Rectangle
        let cgRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let myView = UIImageView()
        myView.frame = cgRect
        myView.backgroundColor = UIColor.clear
        myView.isOpaque = false
        myView.layer.cornerRadius = 10
        myView.layer.borderColor =  UIColor.lightGray.cgColor
        myView.layer.borderWidth = 3
        myView.layer.masksToBounds = true
        myView.tag = 102
        previewLayer?.addSublayer(myView.layer)
        
        // Run preview session on initialization
        previewSession.startRunning()
        
        // Bring the camera button to front
        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(intervalLabel)
        view.bringSubviewToFront(timeLabel)
        
        view.bringSubviewToFront(testLabel)
    }
    
    //MARK: AVCaptureSession settings
    func beginSession() {
        // Prevent pre-running or previous running
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        self.previewLayer?.removeFromSuperlayer()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.iFrame960x540
        
        // Guard permissions of camera
        switch (AVCaptureDevice.authorizationStatus(for: .video)) {
          case .denied:
            print("Denied access to \(AVMediaType.video.rawValue)")
            break
          case .authorized:
            print("Granted access to \(AVMediaType.video.rawValue)")
            break
          case .restricted:
            print("Restricted access to \(AVMediaType.video.rawValue)")
            break
          case .notDetermined:
            print("Access to \(AVMediaType.video.rawValue) is not Determined.\n")
            AVCaptureDevice.requestAccess(for: .video, completionHandler:{ granted in
              print("Checking access to \(AVMediaType.video.rawValue)")
                if granted {
                  print("Granted access to \(AVMediaType.video.rawValue)")
                } else {
                  print("Denied access to \(AVMediaType.video.rawValue)")
                }
            })
            break
        }
        do {
            // Add InputDevice
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)//devices()
            guard
                let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice!),
                captureSession.canAddInput(videoDeviceInput)
                else { return }
            captureSession.addInput(videoDeviceInput)
        }
        
        // Add OutputDataOutput
        videoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,]
        videoCaptureOutput.alwaysDiscardsLateVideoFrames = true
        videoCaptureOutput.setSampleBufferDelegate(self, queue: videoQueue)

        if captureSession.canAddOutput(videoCaptureOutput) {
            captureSession.addOutput(videoCaptureOutput)
        } else {
            print("Cannot add output to session")
        }

        // Add PreviewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        // Add Rectangle
        let cgRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let myView = UIImageView()
        myView.frame = cgRect
        myView.backgroundColor = UIColor.clear
        myView.isOpaque = false
        myView.layer.cornerRadius = 10
        myView.layer.borderColor =  UIColor.red.cgColor
        myView.layer.borderWidth = 3
        myView.layer.masksToBounds = true
        myView.tag = 103
        previewLayer?.addSublayer(myView.layer)
        
        // Bring the camera button to front
        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(intervalLabel)
        view.bringSubviewToFront(timeLabel)
        
        view.bringSubviewToFront(testLabel)
    }
    
    //MARK: - UIStackView
    func createUIStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center // .Leading .FirstBaseline .Center .Trailing .LastBaseline
        stackView.distribution = .fill // .FillEqually .FillProportionally .EqualSpacing .EqualCentering
        stackView.spacing = 15
        
        //Add subview to specific superviews
        self.stackView.addSubview(examTableView)
        self.stackView.addSubview(confirmButton)
        
        self.view.addSubview(stackView)
        
        
        //Layout constraints of stackView
        let constraints = [
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0),
            stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 0),
            stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: 0)
            ]
        NSLayoutConstraint.activate(constraints)
        
        //Layout constraints of confirmButton
        /*confirmButton.bottomAnchor.constraint(equalTo: stackView.layoutMarginsGuide.bottomAnchor, constant: 15).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: CGFloat(50.0)).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: CGFloat(150.0)).isActive = true
        
        //Layout constraints of examTableView
        examTableView.topAnchor.constraint(equalToSystemSpacingBelow: stackView.layoutMarginsGuide.topAnchor, multiplier: 0).isActive = true
        examTableView.leftAnchor.constraint(equalTo: stackView.layoutMarginsGuide.leftAnchor, constant: 0).isActive = true
        examTableView.rightAnchor.constraint(equalTo: stackView.layoutMarginsGuide.rightAnchor, constant: 0).isActive = true
 */
        
        confirmButton.heightAnchor.constraint(equalToConstant: CGFloat(50.0)).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: CGFloat(150.0)).isActive = true
        confirmButton.setImage(#imageLiteral(resourceName: "button_style_10_3"), for: .normal)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension Scoring2ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    //There is only one same method for both of these delegates
    public func captureOutput(_ captureOutput: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        guard captureOutput != nil,
                  sampleBuffer != nil,
                  connection != nil,
                  CMSampleBufferDataIsReady(sampleBuffer) else { return }
        
        if captureOutput == videoCaptureOutput {
            //Important: Correct your video orientation from your device orientation
            /*switch UIDevice.current.orientation {
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                case .portrait:
                    connection.videoOrientation = .portrait
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                default:
                    connection.videoOrientation = .portrait //Make `.portrait` as default (should check will `.faceUp` and `.faceDown`)
            }*/

            //Retreive frame of your buffer
            //Get frame time
            let presTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            let frameTime = CMTimeGetSeconds(presTime)
            if initTimeFlag == 0 {
                currentTime = Int(frameTime) - Int(self.intervalTime/2)
                initTimeFlag = 1
            }
            
            //Save one image per interval
            DispatchQueue.main.async {
                if (Int(frameTime) - self.currentTime) == self.intervalTime &&
                    Int(frameTime) != self.currentTime {
                    //Example:
                    //3 students, interval: 10 sec.
                    //saving will happen at 5, 10, 15 seconds with names Image_1, Image_2, Image_3
                    
                    let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                    let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
                    let image : UIImage = self.convert(cmage: ciimage)
                    
                    self.writeImage(imageName: "\(self.saveNameBase)\(self.saveCount)", image: image)
                    self.saveCount += 1
                    
                    self.currentTime = Int(frameTime) //Avoid multiple images saving at the same time
                }
                
                //self.testLabel.text = "fTime\(Int(frameTime));cnt\(self.saveCount);passTime\(self.passedTime.rounded()))"
            }
        }
    }
}
