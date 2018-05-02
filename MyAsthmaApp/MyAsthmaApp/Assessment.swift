//
//  Assessment.swift
//  MyAsthmaApp
//
//  Created by CCM2308 CCM2308 on 02/03/2018.
//  Copyright © 2018 Hristiyan Trifonov. All rights reserved.
//

import CareKit
import ResearchKit

protocol Assessment: Activity {
    func task() -> ORKTask
}

