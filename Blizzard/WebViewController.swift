//
//  WebViewController.swift
//  Blizzard
//
//  Created by Francisco Ramos on 8/28/17.
//  Copyright © 2017 Francisco Ramos. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: IBOutlet Properties
    
    @IBOutlet weak var webView: UIWebView!
    
    let blizzardKey = "3ugffvbcrudducx3usg764cayf2c8wwx"
    let blizzardSecret = "KSK34qbwj8jSpGTaGBAeCvZF8kMje6U8"
    let authorizationEndPoint = "https://us.battle.net/oauth/authorize"
    let accessTokenEndPoint = "https://us.battle.net/oauth/token"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self

        startAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: IBAction Function
    
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Custom Functions
    
    func startAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"
        
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL = "https://com.francisco.blizzard/oauth".addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        // Create a random string based on the time intervale (it will be in the form linkedin12345679).
        let state = "blizzard\(Int(Date().timeIntervalSince1970))"
        
        // Set preferred scope.
        let scope = "wow.profile"
        
        
        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(blizzardKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        print(authorizationURL)
        
        
        // Create a URL request and load it in the web view.
        let request = URLRequest(url: URL(string: authorizationURL)!)
        webView.loadRequest(request)
    }
    
    
    func requestForAccessToken(_ authorizationCode: String) {
        let grantType = "authorization_code"
        
        let redirectURL = "https://com.francisco.blizzard/oauth".addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
        
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(blizzardKey)&"
        postParams += "client_secret=\(blizzardSecret)"
        
        // Convert the POST parameters into a NSData object.
        let postData = postParams.data(using: String.Encoding.utf8)
        
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(url: URL(string: accessTokenEndPoint)!)
        
        // Indicate that we're about to make a POST request.
        request.httpMethod = "POST"
        
        // Set the HTTP body using the postData object created above.
        request.httpBody = postData
        
        // Add the required HTTP header field.
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        
        // Initialize a NSURLSession object.
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // Make the request.
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)  as! [String:AnyObject]
                    
                    let accessToken = dataDictionary["access_token"] as! String
                    
                    UserDefaults.standard.set(accessToken, forKey: "blizzardAccessToken")
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                }
                catch {
                    print("JSON into dict.")
                }
            }
        })
        
        task.resume()
    }
    
    
    // MARK: UIWebViewDelegate Functions
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        print(url)
        
        if url.host == "com.francisco.blizzard" {
            if url.absoluteString.range(of: "code") != nil {
                // Extract the authorization code.
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let code = urlParts[1].components(separatedBy: "=")[1]
                
                requestForAccessToken(code)
            }
        }
        
        return true
    }
    
}
