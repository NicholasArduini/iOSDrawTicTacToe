//
//  Shape.swift
//  Draw Tic Tac Toe
//
//  Created by Nicholas Arduini on 2016-03-21.
//  Copyright © 2016 Nicholas Arduini. All rights reserved.
//

import Foundation
import CoreGraphics

struct Shape {
    var coordinates = [CGPoint]()
    var shape = " "
    var cell = "q0"
    var cellAvgXPos : CGFloat = 0
    var cellAvgYPos : CGFloat = 0
    
    init(){
        
    }
    
    init(cords: [CGPoint]){
        coordinates = cords
    }
}