//
//  Colors.swift
//  MyAsthmaApp
//
//  Created by user136629 on 4/29/18.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import UIKit

enum Colors {
    
    case menuBlue, brickRed, moduleGrey, borderGrey
    
    var color: UIColor {
        switch self {
        case .menuBlue:
            return UIColor(red: 4/255, green: 120/255, blue: 200/255, alpha: 1)
            
        case .brickRed:
            return UIColor(red: 150/255, green: 40/255, blue: 27/255, alpha: 1)
            
        case .moduleGrey:
            return UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        
        case .borderGrey:
            return UIColor(red: 177/255, green: 177/255, blue: 181/255, alpha: 0.55)
        }
        
        
        
        
    }
    
}
