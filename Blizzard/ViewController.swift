//
//  ViewController.swift
//  Blizzard
//
//  Created by Francisco Ramos on 8/28/17.
//  Copyright © 2017 Francisco Ramos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: IBOutlet Properties
    
    @IBOutlet weak var btnBlizzardSignIn: UIButton!
    
    @IBOutlet weak var btnBlizzardGetProfileInfo: UIButton!
    
    @IBOutlet weak var btnBlizzardOpenProfile: UIButton!
    
    @IBOutlet weak var btnBlizzardOpenID: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnBlizzardSignIn.isEnabled = true
        btnBlizzardGetProfileInfo.isEnabled = false
        btnBlizzardOpenProfile.isHidden = true
        btnBlizzardOpenID.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForExistingAccessToken()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: IBAction Functions
    
    @IBAction func getProfileInfo(_ sender: AnyObject) {
        if let accessToken = UserDefaults.standard.object(forKey: "blizzardAccessToken") {
            // Specify the URL string for access token.

            let targetURLString = "https://us.api.battle.net/account/user?access_token=\(accessToken)"
            
            // Show completed URL string
            print(targetURLString)
            
            let request = NSMutableURLRequest(url: URL(string: targetURLString)!)
            
            request.httpMethod = "GET"
            
            // Init NSURLSession object.
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // Create request.
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    // Convert JSON data into a dictionary.
                    do {
                        let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)  as! [String:AnyObject]
                        dump(dataDictionary)
                        
                        let battletagURLString = dataDictionary.map{"\($0):\($1)"}.joined(separator: "\n\n")
                        
                        print("mapping:",battletagURLString)

                        //Show the battletag
                        print(battletagURLString)
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.btnBlizzardOpenProfile.setTitle(battletagURLString, for: UIControlState())
                            self.btnBlizzardOpenProfile.isHidden = false
                            
                        })
                    }
                    catch {
                        print("JSON conversion error.")
                    }
                }
                
            })
            
            task.resume()
        }
    }
    
    
    @IBAction func openProfileInSafari(_ sender: AnyObject) {
        let profileURL = URL(string: btnBlizzardOpenProfile.title(for: UIControlState())!)
        UIApplication.shared.openURL(profileURL!)
    }
    
    @IBAction func openIDInSafari(_ sender: AnyObject) {
        let idURL = URL(string: btnBlizzardOpenID.title(for: UIControlState())!)
        UIApplication.shared.openURL(idURL!)
    }
    
    
    // MARK: Custom Functions
    
    func checkForExistingAccessToken() {
        if UserDefaults.standard.object(forKey: "blizzardAccessToken") != nil {
            btnBlizzardSignIn.isEnabled = false
            btnBlizzardGetProfileInfo.isEnabled = true
        }
    }
    
}

