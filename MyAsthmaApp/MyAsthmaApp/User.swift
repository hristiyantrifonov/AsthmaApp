//
//  User.swift
//  MyAsthmaApp
//
//  Created by user136629 on 3/14/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import Foundation

class User {
    
    //Properties
    var forename : String?
    var surname : String?
    var email : String?
    
    //Initialiser
    init(withForename: String?,withSurname: String?,withEmail: String?) {
        self.forename = withForename
        self.surname = withSurname
        self.email = withEmail
    }
    
    
}
