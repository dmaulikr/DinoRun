//
//  Fern.swift
//  DinoRun
//
//  Created by Joshua Adams on 1/2/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import Foundation
import SpriteKit

enum FernState: String {
  case oneHundredPercent = "1"
  case seventyFivePercent = "2"
  case fiftyPercent = "3"
  case twentyFivePercent = "4"
  case zeroPercent = "5"
}

class Fern: SKSpriteNode {
  fileprivate var state: FernState = .oneHundredPercent
  fileprivate var textures: [SKTexture] = []
  fileprivate let textureCount = 5
  fileprivate let atlasName = "Fern"
  fileprivate var lastMunched = Date()
  fileprivate let munchInterval: TimeInterval = 1.5
  fileprivate let crunchSound: SKAction = SKAction.playSoundFileNamed("crunch.wav", waitForCompletion: false)

  init() {
    let textureAtlas = SKTextureAtlas(named: atlasName)
    for i in 1...textureCount {
      textures.append(textureAtlas.textureNamed("\(atlasName)\(i).png"))
    }
    super.init(texture: textures[0], color: UIColor.black, size: textures[0].size())
    setState(fernState: .oneHundredPercent)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setState(fernState: FernState) {
    state = fernState
    texture = textures[Int(fernState.rawValue)! - 1]
  }
  
  func munch() {
    let now = Date()
    let munchDiff = now.timeIntervalSince(lastMunched)
    if munchDiff > munchInterval {
      run(crunchSound)
      switch state {
      case .oneHundredPercent:
        setState(fernState: .seventyFivePercent)
      case .seventyFivePercent:
        setState(fernState: .fiftyPercent)
      case .fiftyPercent:
        setState(fernState: .twentyFivePercent)
      case .twentyFivePercent:
        setState(fernState: .zeroPercent)
      case .zeroPercent:
        removeFromParent()
      }
      lastMunched = now
    }
  }
}
