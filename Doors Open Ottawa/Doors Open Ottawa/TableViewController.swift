//
//  TableViewController.swift
//  Doors Open Ottawa
//
//  Created by Zaheed Jaffer on 2018-01-06.
//  Copyright © 2018 Algonquin College. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // The variable blow is to hold the data that is recieved from the server
    var jsonObjects: [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Url where the data is coming from
        let requestUrl: URL = URL(string: "https://doors-open-ottawa.mybluemix.net/buildings")!
        
        // Create the request object and pass the url
        let myRequest: URLRequest = URLRequest(url: requestUrl)
        
        // Create the URLSession object that will intiate the request for the data
        let mySession: URLSession = URLSession.shared
        
        // Create te specific task using the session
        let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask )
        // Tell the task to runnnnnnn forresst run
        myTask.resume()

    }
    
    // The Callback funtion handles what happens after a response is heard
    func myCallback(_ responseString: String, error: String?) {
        
        // If an error is passed in and outputs the error to the console
        if error != nil {
            print("DATA LIST LOADING ERROR: " + error!)
        }else{
            // If there is no error then the reponse is printed to the console
            print("DATA RECEIVED: " + responseString)
            
            // Turns the stringified data back to the raw data
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    // Tries to save the data to a ditionary
                    jsonObjects = try JSONSerialization.jsonObject(with: myData, options: []) as? [[String:Any]]
                    
                } catch let convertError {
                    // If the data cannot be converted to raw data the error is displayed in the console
                    print(convertError.localizedDescription)
                }
                
            }
            
            // Updates the UI
            DispatchQueue.main.async {
                // Reloads the table view
                self.tableView!.reloadData()
                // Sets title to event list
                self.title = "Building List"
            }
        }
    }
    
    func requestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // This will create the error if the sever connot be reached
        if serverError != nil {
            // Calls the callback funtion and passs in the string and the errorn
            self.myCallback("", error: serverError?.localizedDescription)
            
        }else{
            // if there is no error then the data stringifyed to the result object
            let result = String(data: serverData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            // Calls the callback function and passes in the strigfyied data and nil for the error
            self.myCallback(result, error: nil)
            
        }
    }



    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellCount = 0
        
        if let jsonObj = jsonObjects {
            cellCount = jsonObj.count
        }
        
        return cellCount

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath)

        //Sets the cell data
        if let jsonObj = jsonObjects{
            
            // For the current tableCell row get the corresponding planet's dictionary of info
            let dictionaryRow = jsonObj[indexPath.row] as [String:Any]
            
            // Get the name and overview for the current planet
            let name = dictionaryRow["nameEN"] as? String
            let address = dictionaryRow["addressEN"] as? String
            
            // Add the name and overview to the cell's textLabel
            // Also changes the line number allowing the address and name are on seperate lines
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = name! + "\n" + address!
        }

        return cell
    }
    
    // Pass the current planet id to the next view when a cell is clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBuilding" {
            // Get a reference to the next viewController class
            let nextVC = segue.destination as? ViewController
            
            // Get a reference to the cell that was clicked
            let thisCell = sender as? UITableViewCell
            // Set the planetId value of the next viewController
            let buildingID = tableView.indexPath(for: thisCell!)!.row
            
            // Use optional binding to access the JSON dictionary if it exists
            if let jsonObj = jsonObjects{
                nextVC?.jsonObj = jsonObj[buildingID] as [String:Any]
            }
        }
    }
}
