//
//  Dinosaur.swift
//  VirtualJoystick
//
//  Created by Joshua Adams on 9/2/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation
import SpriteKit

enum DinosaurType: String {
  case stegosaurus = "Stegosaurus"
  case raptor = "Raptor"
}

enum DinosaurState: String {
  case idle = "Idle"
  case walk = "Walk"
  case dead = "Dead"
  case run = "Run"
}

class Dinosaur: SKSpriteNode {
  fileprivate var direction: Direction = .east
  fileprivate var state: DinosaurState = .idle
  fileprivate var eastIdleTextures: [SKTexture] = []
  fileprivate var westIdleTextures: [SKTexture] = []
  fileprivate var eastWalkTextures: [SKTexture] = []
  fileprivate var westWalkTextures: [SKTexture] = []
  fileprivate var eastDeadTextures: [SKTexture] = []
  fileprivate var westDeadTextures: [SKTexture] = []
  fileprivate var westRunTextures: [SKTexture] = []
  fileprivate let eastIdleAnimation: SKAction!
  fileprivate let westIdleAnimation: SKAction!
  fileprivate let eastWalkAnimation: SKAction!
  fileprivate let westWalkAnimation: SKAction!
  fileprivate let eastDeadAnimation: SKAction!
  fileprivate let westDeadAnimation: SKAction!
  fileprivate let westRunAnimation: SKAction!
  fileprivate let stegosaurusTextureCount = 10
  fileprivate let raptorTextureCount = 8
  fileprivate let timePerFrame: TimeInterval = 0.1
  fileprivate let dinosaurType: DinosaurType
  
  init(dinosaurType: DinosaurType) {
    self.dinosaurType = dinosaurType
    switch dinosaurType {
    case .stegosaurus:
      let stegosaurusAtlas = SKTextureAtlas(named: dinosaurType.rawValue)
      for i in 1...stegosaurusTextureCount {
        eastIdleTextures.append(stegosaurusAtlas.textureNamed("eIdle\(i).png"))
        westIdleTextures.append(stegosaurusAtlas.textureNamed("wIdle\(i).png"))
        eastWalkTextures.append(stegosaurusAtlas.textureNamed("eWalk\(i).png"))
        westWalkTextures.append(stegosaurusAtlas.textureNamed("wWalk\(i).png"))
        eastDeadTextures.append(stegosaurusAtlas.textureNamed("eDead\(i).png"))
        westDeadTextures.append(stegosaurusAtlas.textureNamed("wDead\(i).png"))
      }
      eastIdleAnimation = SKAction.animate(with: eastIdleTextures, timePerFrame: timePerFrame)
      westIdleAnimation = SKAction.animate(with: westIdleTextures, timePerFrame: timePerFrame)
      eastWalkAnimation = SKAction.animate(with: eastWalkTextures, timePerFrame: timePerFrame)
      westWalkAnimation = SKAction.animate(with: westWalkTextures, timePerFrame: timePerFrame)
      eastDeadAnimation = SKAction.animate(with: eastDeadTextures, timePerFrame: timePerFrame)
      westDeadAnimation = SKAction.animate(with: westDeadTextures, timePerFrame: timePerFrame)
      westRunAnimation = nil
      super.init(texture: eastIdleTextures[0], color: UIColor.black, size: eastIdleTextures[0].size())
      setState(dinosaurState: .idle, direction: .east)
    case .raptor:
      let raptorAtlas = SKTextureAtlas(named: dinosaurType.rawValue)
      for i in 1...raptorTextureCount {
        westRunTextures.append(raptorAtlas.textureNamed("wRun\(i).png"))
      }
      westRunAnimation = SKAction.animate(with: westRunTextures, timePerFrame: timePerFrame)
      eastIdleAnimation = nil
      westIdleAnimation = nil
      eastWalkAnimation = nil
      westWalkAnimation = nil
      eastDeadAnimation = nil
      westDeadAnimation = nil
      super.init(texture: westRunTextures[0], color: UIColor.black, size: westRunTextures[0].size())
      setState(dinosaurState: .run, direction: .west)
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setState(dinosaurState: DinosaurState, direction: Direction) {
    state = dinosaurState
    self.direction = direction
    switch dinosaurType {
    case .stegosaurus:
      if state == .idle && (direction == .east || direction == .northeast || direction == .southeast || direction == .north || direction == .center) {
        if action(forKey: "east idle") == nil {
          removeAction(forKey: "east walk")
          removeAction(forKey: "west walk")
          removeAction(forKey: "west idle")
          run(SKAction.repeatForever(eastIdleAnimation), withKey: "east idle")
        }
      }
      if state == .idle && (direction == .west || direction == .northwest || direction == .southwest || direction == .south) {
        if action(forKey: "west idle") == nil {
          removeAction(forKey: "east walk")
          removeAction(forKey: "west walk")
          removeAction(forKey: "east idle")
          run(SKAction.repeatForever(westIdleAnimation), withKey: "west idle")
        }
      }
      if state == .walk && (direction == .east || direction == .northeast || direction == .southeast || direction == .north || direction == .center) {
        if action(forKey: "east walk") == nil {
          removeAction(forKey: "east idle")
          removeAction(forKey: "west walk")
          removeAction(forKey: "west idle")
          run(SKAction.repeatForever(eastWalkAnimation), withKey: "east walk")
        }
      }
      if state == .walk && (direction == .west || direction == .northwest || direction == .southwest || direction == .south) {
        if action(forKey: "west walk") == nil {
          removeAction(forKey: "east walk")
          removeAction(forKey: "east idle")
          removeAction(forKey: "west idle")
          run(SKAction.repeatForever(westWalkAnimation), withKey: "west walk")
        }
      }
      case .raptor:
        run(SKAction.repeatForever(westRunAnimation), withKey: "west run")
    }
  }
}
