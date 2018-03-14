//
//  ViewController.swift
//  Doors Open Ottawa
//
//  Created by Zaheed Jaffer on 2018-01-06.
//  Copyright © 2018 Algonquin College. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var buildingTitle: UITextField!
    @IBOutlet weak var buildingDesciptions: UITextView!
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var buildingMap: MKMapView!
    
    var jsonObj: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildingTitle.text = jsonObj!["nameEN"] as? String
        buildingDesciptions.text = jsonObj!["descriptionEN"] as? String
        // Sets building address using the address, city and province
        let buildingAddress: String? = jsonObj!["addressEN"] as? String
        let buildingCity: String? = jsonObj!["city"] as? String
        let buildingProvince: String? = jsonObj!["province"] as? String
        let wholeAddress: String? = buildingAddress! + "," + buildingCity! + "," + buildingProvince!
        
        let geocodedAddresses = CLGeocoder()
        geocodedAddresses.geocodeAddressString(wholeAddress!, completionHandler: placeMarkerHandler)
        
        buildingImageDisplay()
    }
    
    func placeMarkerHandler (placeMarkers: Optional<Array<CLPlacemark>>, error: Optional<Error>) -> Void{
        if let firstMarker = placeMarkers?[0] {
            let marker = MKPlacemark(placemark: firstMarker)
            self.buildingMap?.addAnnotation(marker)
            let myRegion = MKCoordinateRegionMakeWithDistance(marker.coordinate, 500, 500)
            self.buildingMap?.setRegion(myRegion, animated: false)
        }
    }
    
    func buildingImageDisplay() {
        

        let buildingID = jsonObj!["buildingId"] as? Int
        
        // Url where the data is coming from
        let requestUrl: URL = URL(string: "https://doors-open-ottawa.mybluemix.net/buildings/\(buildingID!)/image")!
        
        // Create the request object and pass the url
        let myRequest: URLRequest = URLRequest(url: requestUrl)
        
        // Create the URLSession object that will intiate the request for the data
        let mySession: URLSession = URLSession.shared
        
        let imageTask = mySession.dataTask(with: myRequest, completionHandler: requestTask)
        // Run the task
        imageTask.resume()
        
    }
    
    func requestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // This will create the error if the sever connot be reached
        if serverError != nil {
            // Calls the callback funtion and passs in the string and the error
            print("IMAGE ERROR: " + serverError!.localizedDescription)
        }else{
            // Dispatch will update the UI on the main thread 
            DispatchQueue.main.async {
                self.buildingImage.image = UIImage(data: serverData!)
            }
        }
    }
}
    

