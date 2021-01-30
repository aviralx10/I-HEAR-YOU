//
//  DetectViewController.swift
//  I Hear You
//
//  Created by Aviral Yadav on 29/01/21.
//

import UIKit
import Vision

class DetectViewController: UIViewController {
    
    var originalImage: UIImage?
    var answer:String?
    
    lazy var inputImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        image.clipsToBounds = false
        return image
    }()
    
    lazy var saveImage: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToSaveImage(_:)), for: .touchUpInside)
        button.setTitle("Detect", for: .normal)
        
        return button
    }()


    
    lazy var dissmissButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToDissmiss(_:)), for: .touchUpInside)
        button.setTitle("Dismiss", for: .normal)
        let icon = UIImage(systemName: "xmark.circle")?.resized(newSize: CGSize(width: 35, height: 35))
        let tintedImage = icon?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLetter()
    }
    
    func addSubviews() {
        view.addSubview(inputImage)
        view.addSubview(saveImage)
        //view.addSubview(myLabel)
        view.addSubview(dissmissButton)
    }
    
    func setupLayout() {
        inputImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        inputImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputImage.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        inputImage.heightAnchor.constraint(equalToConstant: (inputImage.image?.size.height)!*view.frame.width/(inputImage.image?.size.width)!).isActive = true
        inputImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        saveImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        saveImage.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        saveImage.bottomAnchor.constraint(equalTo: dissmissButton.topAnchor, constant: -40).isActive = true
        
        dissmissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dissmissButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        dissmissButton.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        dissmissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
    }
    func showLetter(){
     
        guard let model = try? VNCoreMLModel(for:  iHear().model) else { return }
        guard let image = self.inputImage.image
                                    else{return}
    
    guard let ciImage = CIImage(image: image)
                    else{return}
    let request = VNCoreMLRequest(model: model) { request, error in
                    let results = request.results?.first as? VNClassificationObservation
        
        self.answer=results?.identifier ?? "Error"
                    
                    
                }
    let handler = VNImageRequestHandler(ciImage: ciImage)
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try handler.perform([request])
                    } catch {
                        print(error)
                    }
                }

        
    }
    

    


    
    @objc func buttonToDissmiss(_ sender: CustomButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonToSaveImage(_ sender: CustomButton) {
        let alert = UIAlertController(title: "PREDICTION", message:"The predicted letter is \(answer ?? "NOTHING")   (ACCURACY-73%)", preferredStyle: UIAlertController.Style.alert)

                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            triggerAlert(title: "Error while saving", message: error.localizedDescription)
        } else {
            triggerAlert(title: "Saved", message: "You can find your image in the photo library")
        }
    }
    
    func triggerAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

