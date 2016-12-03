//
//  Font.swift
//  MoneyLevel
//
//  Created by Josh Adams on 10/8/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit

enum Font: String {
  case chalkboard = "ChalkboardSE-Regular"
  
  // MARK: property
  
  static let scaleFactor: CGFloat = 667.0
  
  // MARK: methods
  
  func makeFont(size: CGFloat) -> UIFont {
    return UIFont(name: self.rawValue, size: scaledSize(sizeOnIPhone6: size))!
  }
  
  private func scaledSize(sizeOnIPhone6: CGFloat) -> CGFloat {
    return sizeOnIPhone6 * (UIScreen.main.bounds.size.height / Font.scaleFactor)
  }
}
