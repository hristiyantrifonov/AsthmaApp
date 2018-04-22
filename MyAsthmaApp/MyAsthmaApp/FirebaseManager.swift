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
    
    
    typealias Value = (Any?) -> Void
    
    //MARK: - General System Methods
    
    /*
     Fetch the requests which were addressed for a specific doctor
     */
    func fetchDoctorRequests(doctorID : String, completion : @escaping Value){
        
        var requestsArray : Array<String> = []
        
        ref.child("requests").queryOrderedByKey().observeSingleEvent(of: .value ,with: {
            (snapshot) in
            
            let allRequests = snapshot.value as? NSDictionary
            
            if allRequests != nil {
                for request in allRequests!{
                    let req = request.value as! NSDictionary
                    
                    let doctor = req["Doctor"] as? String ?? ""
                    let patient = req["Patient"] as? String ?? ""
                    
                    print("Request for Doctor: \(doctor)")
                    
                    if doctor == doctorID{
                        print("Matched request from \(patient) with \(request.key)")
                        requestsArray.append(request.key as! String)
                    }
                }
                completion(requestsArray)
            }else{
                completion(nil)
            }
            
        })
    }
    
    
    /*
     Fetch the requests which were sent by the patient for doctor's approval
     */
    func fetchPatientSubmittedRequests(patientID : String, completion : @escaping Value){
        
        var requestsArray : Array<String> = []
        
        ref.child("requests").queryOrderedByKey().observeSingleEvent(of: .value ,with: {
            (snapshot) in
            
            let allRequests = snapshot.value as? NSDictionary
            
            if allRequests != nil {
                for request in allRequests!{
                    let req = request.value as! NSDictionary
                    
                    let patient = req["Patient"] as? String ?? ""
                    print("Request from Patient: \(patient)")
                    
                    if patient == patientID{
                        print("Matched request \(patient) with \(request.key)")
                        requestsArray.append(request.key as! String)
                    }
                }
                completion(requestsArray)
            }else{
                completion(nil)
            }
            
        })
    }
    
    /*
     Creates the different kinds of requests based on the action identifier. Requests differ in the way their Parameters are stored
     */
    
    func makeAlteringRequest(fromPatient patientID : String, toDoctor doctorID : String, requestIdentifier : String, parameters : NSArray ){
        
        print(parameters)
        
        if requestIdentifier == "Add Activity"{
            
            ref.child("requests").childByAutoId().setValue(["Identifier" : requestIdentifier, "Patient" : patientID, "Doctor" : doctorID, "Authorised" : false, "Parameters" :
                (["Title" : parameters[0], "Summary" : parameters[1], "Instructions" : parameters[2], "Group-Identifier" : parameters[3], "Schedule" : parameters[4], "Optionality" : parameters[5] ]) ])
            
        }
        else if requestIdentifier == "Add Scale Assessment"{
            
            ref.child("requests").childByAutoId().setValue(["Identifier" : requestIdentifier, "Patient" : patientID, "Doctor" : doctorID, "Authorised" : false, "Parameters" :
                (["Title" : parameters[0], "Summary" : parameters[1], "Description" : parameters[2], "Max" : parameters[3], "Min" : parameters[4], "Optionality" : parameters[5] ]) ])
            
        }
        else if requestIdentifier == "Add Quantity Assessment" {
            
            ref.child("requests").childByAutoId().setValue(["Identifier" : requestIdentifier, "Patient" : patientID, "Doctor" : doctorID, "Authorised" : false, "Parameters" :
                (["Title" : parameters[0], "Summary" : parameters[1], "Description" : parameters[2], "Type-Category" : parameters[3], "Unit" : parameters[4], "Optionality" : parameters[5]]) ])
            
        }
        else if requestIdentifier == "End Activity"{
            
            ref.child("requests").childByAutoId().setValue(["Identifier" : requestIdentifier, "Patient" : patientID, "Doctor" : doctorID, "Authorised" : false, "Parameters" :
                (["Target" : parameters[0], "End-Day" : parameters[1], "End-Month" : parameters[2], "End-Year" : parameters[3] ]) ])
            
        }
        else{
            print("UNKNOWN TYPE OF REQUEST.")
        }
        
    }
    
    
    
    //MARK: - Patient-Specific Methods
    
    /*
    Returns the patient's profile with all its fields
    */
    func getPatientFields(patientID : String, completion : @escaping Value){
        ref.child("users").child(patientID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let patient = snapshot.value as? NSDictionary
            
            if patient != nil{
                completion(patient)
            }else{
                completion(nil)
            }
        })
    }
    
    /*
     Returns a specified field value of a user/patient
     */
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
    
    /*
     Changes a desired field of a user/patient object with the specified value
     */
    func changeUserField(userID : String, key : String, value : Any){
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userObject = snapshot.value as? NSDictionary
            
            userObject?.setValue(value, forKey: key)
            
            self.ref.child("users").child(userID).setValue(userObject)
            
        })
    }
    
    /*
     Finds who is the doctor of a patient with ID given in the parameter
     */
    func findPatientDoctor(patientID : String, completion : @escaping Value){
        
        ref.child("doctors_patients").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let allRelationships = snapshot.value as? NSDictionary
            
            if allRelationships != nil{
                for relationship in allRelationships! {
                    let relation = relationship.value as! NSDictionary
                    
                    let patient = relation["Patient"] as? String ?? ""
                    let doctor = relation["Doctor"] as? String ?? ""
                    
                    if patient == patientID{
                        completion(doctor)
                    }
                }
            }else{
                completion(nil)
            }
        })
        
    }
    
    func findPatientContacts(patientID : String, completion : @escaping Value){
        
        ref.child("contacts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let allContacts = snapshot.value as? NSDictionary
            
            if let contactKeys = allContacts?.allKeys {
                
                for key in contactKeys{
                    print("key : \(key)")
                    let contactObject = allContacts!["\(key)"] as! NSDictionary
                    
                    completion(contactObject[patientID])
                    
                }
            }else{
                print("No contacts")
                completion(nil)
            }
        
        })
        
    }
    
    
    
    //MARK: - Requests-Specific Methods
    
    /*
     Returns the request db object with all its fields
     */
    
    func getRequestFields(requestID : String, completion : @escaping Value){
        
        ref.child("requests").child(requestID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let request = snapshot.value as? NSDictionary
            
            if request != nil{
                completion(request)
            }else{
                completion(nil)
            }
        })
    }
    
    /*
     Returns whether the request has been approved/rejected or is on pending
     */
    func getRequestStatus(requestID : String, completion : @escaping Value){
        ref.child("requests").child(requestID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let request = snapshot.value as? NSDictionary
            
            if request != nil{
                let status = request!["Authorised"] as! Bool
                completion(status)
            }else{
                completion(nil)
            }
        })
    }
    
    
    /*
        Sets the decision made by the doctor whether to allow change or not
     */
    
    func changeRequestAuthorisationStatus(requestID : String, authorisation : Bool){
        ref.child("requests").child(requestID).observeSingleEvent(of: .value, with: { (snapshot) in
            let requestObject = snapshot.value as! NSDictionary
            
            requestObject.setValue(authorisation, forKey: "Authorised")
            requestObject.setValue(true, forKey: "Reviewed")
            
            self.ref.child("requests").child(requestID).setValue(requestObject)
        })
    }
    
    /*
        Deletes a request record from the database
     */
    func removeRequest(requestID : String){
        print("REMOVING REQUEST \(requestID)")
        ref.child("requests").child(requestID).removeValue { error, _ in
            print(error)
        }
    }
    
    //MARK: - Contacts Methods
    
    func addNewContact(patientID : String, contactDetails: [String : Any],completion: @escaping Value){
        
        if contactDetails.count > 0{
            ref.child("contacts").childByAutoId().child(patientID).setValue(contactDetails)
            
            completion(true)
        }else{
            completion(false)
        }
    }
    
    
}
