//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by Carlos Guedes on 14/03/2019.
//  Copyright © 2019 Carlos Guedes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
 
    override func viewDidLoad() {
        
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
    }


}

