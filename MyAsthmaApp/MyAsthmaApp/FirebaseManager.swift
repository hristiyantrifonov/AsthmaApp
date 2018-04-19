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
    var userFieldValue : Any?
    
    init() {
        ref = Database.database().reference()
        userFieldValue = nil
    }
    
    func changeUserField(userID : String, key : String, value : Any){
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userObject = snapshot.value as? NSDictionary
            
            userObject?.setValue(value, forKey: key)
            
            self.ref.child("users").child(userID).setValue(userObject)
            
        })
    }
    
    typealias Value = (Any?) -> Void
    
    func returnUserField(userID : String, key : String, completion : @escaping Value) {
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userObject = snapshot.value as? NSDictionary
            
            let fieldValue = userObject![key]
            
            if fieldValue == nil{
                completion(nil)
            }else{
                completion(fieldValue)
            }
        })
    }
    
    //TODO this will be used for making requests
    func makeAlteringRequest(){
        
    }
    
    
}
