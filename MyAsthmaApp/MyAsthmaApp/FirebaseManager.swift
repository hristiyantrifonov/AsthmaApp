//
//  FirebaseManager.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/17/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    func changeUserField(userID : String, key : String, value : Any){
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userObject = snapshot.value as? NSDictionary
            
            userObject?.setValue(value, forKey: key)
            
            self.ref.child("users").child(userID).setValue(userObject)
            
        })
    }
    
    func returnUserField(userID : String, key : String) -> Any {
        
        var valueToBeReturned : (Any)? = nil
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userObject = snapshot.value as? NSDictionary
            
            let fieldValue = userObject![key]
            print("this")
            print(fieldValue)
            valueToBeReturned = fieldValue
            print("now")
            print(fieldValue)
            print(valueToBeReturned)
            
            
        })
        
        return valueToBeReturned
    }
    
    
}
