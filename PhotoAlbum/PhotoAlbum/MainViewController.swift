//
//  MainViewController.swift
//  PhotoAlbum
//
//  Created by Carlos Guedes on 14/03/2019.
//  Copyright © 2019 Carlos Guedes. All rights reserved.
//

import UIKit
import CoreML
import Vision
import CoreData
import MapKit
import CoreLocation

extension Date {
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  CLLocationManagerDelegate {
    
     var locationManager = CLLocationManager()

    @IBOutlet weak var predictLabel: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var hammerButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var saveLabel: UIBarButtonItem!
    
    var latitude: Double = 0
    var longitude: Double = 0
    
    var picURL = NSURL(string: "")
    
    @IBAction func predictButton(_ sender: Any) {
        let imageURL = picURL!
        
        let modelFile = MobileNet()
        let model = try! VNCoreMLModel(for: modelFile.model)
        
        let handler = VNImageRequestHandler(url: imageURL as URL)
        let request = VNCoreMLRequest(model: model, completionHandler: findResults)
        
        try! handler.perform([request])
        //enable save button and disable prediction button
        saveLabel.isEnabled = true
        hammerButton.isEnabled = false
        predictLabel.isEnabled = false
    }
    
    @IBAction func saveButton(_ sender: Any) {
        savingData()
        saveLabel.isEnabled = false
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //set user's location
        latitude = locValue.latitude
        longitude = locValue.longitude
        //print ("1.location: Lat=\(latitude) Long=\(longitude)")
    }
    
    @IBAction func loadButton(_ sender: Any) {
        //clear results
        resultLabel.text = ""
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(photoLibraryAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            //let imageData = NSData(contentsOfFile: localPath!)!
            let photoURL = URL.init(fileURLWithPath: localPath!)//NSURL(fileURLWithPath: localPath!)
            
            picURL = photoURL as NSURL
            imageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
        hammerButton.isEnabled = true
        predictLabel.isEnabled = true
    }
    
    func findResults(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Unable to get results")
        }
        
        var bestGuess = ""
        var bestConfidence: VNConfidence = 0
        
        for classification in results {
            if (classification.confidence > bestConfidence) {
                bestConfidence = classification.confidence
                bestGuess = classification.identifier
            }
        }
        resultLabel.text = "Image is: \(bestGuess) with confidence \(bestConfidence) out of 1"
    }
    
    func savingData(){
        
        let alert = UIAlertController(title: "Saved", message: "Your results data have saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //Create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
        
        //Save inside the Core Data
        let dataObject = NSManagedObject(entity: userEntity, insertInto: managedContext)
        dataObject.setValue(Date(), forKeyPath: "date")
        dataObject.setValue(resultLabel.text, forKey: "result")
        dataObject.setValue(latitude, forKey: "latitude")
        dataObject.setValue(longitude, forKey: "longitude")
        
        do {
            try managedContext.save()
            // Present dialog message to user
            self.present(alert, animated: true, completion: nil)
             print("Data saved!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request to get user's location
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        //define image file
        if let image = UIImage(named: "coreml.png") {
            let originalImage = CIImage(image: image)
            
            // define filter type
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setDefaults()
            filter?.setValue(originalImage, forKey: kCIInputImageKey)
            
            // output image
            if let outputImage = filter?.outputImage {
                let newImage = UIImage(ciImage: outputImage)
                imageView.image = newImage
            }
        }
        hammerButton.isEnabled = false
        predictLabel.isEnabled = false
        saveLabel.isEnabled = false
    }
}
