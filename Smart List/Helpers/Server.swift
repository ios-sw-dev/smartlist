//
//  Server.swift
//  Smart List
//
//  Created by Haamed Sultani on Apr/1/19.
//  Copyright © 2019 Haamed Sultani. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


/// A Singleton that handles all the API requests
class Server {
    
    static let shared = Server()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
    }
    
    // Nurtirionix API properties
    let nutriAppID : String = "b3bc8e5b"                                    // Nutritionix App ID
    let nutriAppKey : String = "868c6f6027df0a34334a232b2543b5bf"           // Nutritionix App Key
    let remoteUserID : String = "0"                                         // Remote User ID = 0 (development)
    let NUTRITIONIX_API : String = "https://trackapi.nutritionix.com/"      // Base URL for requests
    
    // Smart List API properties
    let SMARTLIST_DB_API : String = Constants.General.Server                   // Base URL for MongoDB requests
    
    /// Make a request to Nutritionix API for nutritional information of an Item
    func searchItem(itemName : String) {
        AF.request("\(NUTRITIONIX_API)/v2/natural/nutrients",
            method: .post,
            parameters: ["query" : itemName],
            headers: ["x-app-id" : self.nutriAppID, "x-app-key" : self.nutriAppKey, "x-remote-user-id" : self.remoteUserID]).responseJSON {
                
                response in
                
                switch response.result {
                case .success(let data):                            // If request was a success
                    print("Nutrients endpoint success")
                    print(JSON(data))
                case .failure(let error):                           // If request was a failure
                    print("Nutrients endpoint failure: \(error)")
                }
        }
    }
    
    
    
    /// Makes a request to Nutritionix API to get the URL for the thumbnail image of a specified Item
    ///
    /// - Parameters:
    ///   - itemName: The name of the Item entity
    ///   - callBack: Used for returning the data fetched from the request
    func getItemThumbnailURL(itemName: String, callBack: @escaping (_ imageURL: String) -> Void) {
        
        AF.request("\(NUTRITIONIX_API)/v2/natural/nutrients",                                      // Endpoint
            method: .post,
            parameters: ["query" : itemName],                                           // Parameters/body of the request
            headers: ["x-app-id" : self.nutriAppID, "x-app-key" : self.nutriAppKey, "x-remote-user-id" : self.remoteUserID]).responseJSON {
                
                response in
                
                switch response.result {
                case .success(let data):                                                 // If the request was a success
                    callBack(JSON(data)["foods"][0]["photo"]["thumb"].stringValue)      // Return the string value of the URL
                    
                case .failure(let error):                                               // The request failed
                    print("Search Nutritionix For Image failed: \(error)")
                }
        }
    }
    
    
    /// Makes a request to the Nutritionix API to get the URL for the full image of the specified Item
    ///
    /// - Parameters:
    ///   - itemName: The name of the Item in question
    ///   - callBack: Used to return the data fetched from the request
    func getItemFullURL(itemName: String, callBack: @escaping (_ imageURL: String) -> Void) {
        
        AF.request("\(NUTRITIONIX_API)/v2/natural/nutrients",                                      // Endpoint
            method: .post,
            parameters: ["query" : itemName],                                           // Parameters/body of the request
            headers: ["x-app-id" : self.nutriAppID, "x-app-key" : self.nutriAppKey, "x-remote-user-id" : self.remoteUserID]).responseJSON {
                
                response in
                
                switch response.result {
                case .success(let data):                                                 // IF the request was a success
                    callBack(JSON(data)["foods"][0]["photo"]["highres"].stringValue)    // Return the string value of the URL
                    
                case .failure(let error):                                               // The request failed
                    print("Search Nutritionix For Image failed: \(error)")
                }
        }
    }
    
    
    
    /// Sends a request to the server to create a new User in the DB
    ///
    /// - Parameters:
    ///   - name: The user's name
    ///   - email: the user's email; must be unique and valid
    ///   - password: The user'spassword; must be 8+ characters
    ///   - callBack: callback returning the JSON data
    func signUpNewUser(name: String, email: String, password: String, callBack: @escaping (_ newUser: [String:String]) -> Void) {
        
        let params = ["name" : name, "email" : email, "password" : password]    // The body
        
        AF.request("\(SMARTLIST_DB_API)/users",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default).responseJSON {
                response in
                
                switch response.result {
                case .success(let data):
                    let obj = JSON(data)                                            // Get JSON
                    print(obj)
                    
                    let name = obj["user"]["name"].stringValue                      // Get name
                    let email = obj["user"]["email"].stringValue                    // Get email
                    
                    callBack(["name": name, "email": email])                        // callback
                    
                case .failure(let error):
                    print("Error when trying to create a new User: \n\(error)")
                    
                    callBack(["error": error.localizedDescription])
                }
        }
    }
}
