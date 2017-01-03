//
//  Direction.swift
//  VirtualJoystick
//
//  Created by Joshua Adams on 9/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

enum Direction {
  case error
  case center
  case east
  case northeast
  case north
  case northwest
  case west
  case southwest
  case south
  case southeast
  
  init() {
    self = .center
  }
  
  mutating func setDirection(_ degrees: CGFloat) {
    let sixteenth = CGFloat(360.0) / CGFloat(16.0)
    
    if degrees < 0 || degrees > 360 {
      self = .error
    }
    else if degrees < sixteenth || degrees >= 15 * sixteenth {
      self = .east
    }
    else if degrees >= sixteenth && degrees < 3 * sixteenth {
      self = .northeast
    }
    else if degrees >= 3 * sixteenth && degrees < 5 * sixteenth {
      self = .north
    }
    else if degrees >= 5 * sixteenth && degrees < 7 * sixteenth {
      self = .northwest
    }
    else if degrees >= 7 * sixteenth && degrees < 9 * sixteenth {
      self = .west
    }
    else if degrees >= 9 * sixteenth && degrees < 11 * sixteenth {
      self = .southwest
    }
    else if degrees >= 11 * sixteenth && degrees < 13 * sixteenth {
      self = .south
    }
    else { // if degrees >= 13 * sixteenth && degrees < 15 * sixteenth
      self = .southeast
    }
  }
}
