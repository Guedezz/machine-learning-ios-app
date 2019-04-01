//
//  TTableViewController.swift
//  PhotoAlbum
//
//  Created by Carlos Guedes on 26/03/2019.
//  Copyright © 2019 Carlos Guedes. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var DBObject = [Results] ()
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var map: MKMapView!

    var date: Date = Date()
    var classif_results: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
    }
    
    
    func retrieveData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")

        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: true)]
        
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                
                print(data.value(forKey: "date") as! Date)
                date = (data.value(forKey:"date") as? Date)!
                classif_results = (data.value(forKey:"result") as? String)!
                latitude = (data.value(forKey:"latitude") as? Double)!
                longitude = (data.value(forKey:"longitude") as? Double)!
                
                // insert values into array
                DBObject.append(Results(date: date, result: classif_results, latitude: latitude, longitude: longitude))
                print("Print data: \(data)")
            }
        } catch {
            
            print("Failed")
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DBObject.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = DBObject[indexPath.row].date.asString(style: .full)
        return cell
    }
    
    //fetch selected record
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {return}
        resultLabel.text = DBObject[selectedIndexPath.row].result
        
        latitude = DBObject[selectedIndexPath.row].latitude
        longitude = DBObject[selectedIndexPath.row].longitude
        
        let locationCoord : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        //let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (locationCoord), latitudinalMeters: 600, longitudinalMeters: 600)
        
        //let viewRegion =
        self.map.setRegion(viewRegion, animated: true)
        self.map.showsUserLocation = true
    }
}
