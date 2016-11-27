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
  fileprivate let eastIdleAnimation: SKAction
  fileprivate let westIdleAnimation: SKAction
  fileprivate let eastWalkAnimation: SKAction
  fileprivate let westWalkAnimation: SKAction
  fileprivate let eastDeadAnimation: SKAction
  fileprivate let westDeadAnimation: SKAction
  fileprivate let westRunAnimation: SKAction
  fileprivate let stegosaurusTextureCount = 10
  fileprivate let raptorTextureCount = 8
  fileprivate let timePerFrame: TimeInterval = 0.1
  fileprivate let dinosaurType: DinosaurType
  
  init(dinosaurType: DinosaurType) {
    self.dinosaurType = dinosaurType
    let textureAtlas = SKTextureAtlas(named: dinosaurType.rawValue)
    
    for i in 1...stegosaurusTextureCount {
      eastIdleTextures.append(textureAtlas.textureNamed("eIdle\(i).png"))
      westIdleTextures.append(textureAtlas.textureNamed("wIdle\(i).png"))
      eastWalkTextures.append(textureAtlas.textureNamed("eWalk\(i).png"))
      westWalkTextures.append(textureAtlas.textureNamed("wWalk\(i).png"))
      eastDeadTextures.append(textureAtlas.textureNamed("eDead\(i).png"))
      westDeadTextures.append(textureAtlas.textureNamed("wDead\(i).png"))
    }

    for i in 1...raptorTextureCount {
      westRunTextures.append(textureAtlas.textureNamed("wRun\(i).png"))
    }
    
    eastIdleAnimation = SKAction.animate(with: eastIdleTextures, timePerFrame: timePerFrame)
    westIdleAnimation = SKAction.animate(with: westIdleTextures, timePerFrame: timePerFrame)
    eastWalkAnimation = SKAction.animate(with: eastWalkTextures, timePerFrame: timePerFrame)
    westWalkAnimation = SKAction.animate(with: westWalkTextures, timePerFrame: timePerFrame)
    eastDeadAnimation = SKAction.animate(with: eastDeadTextures, timePerFrame: timePerFrame)
    westDeadAnimation = SKAction.animate(with: westDeadTextures, timePerFrame: timePerFrame)
    westRunAnimation = SKAction.animate(with: westRunTextures, timePerFrame: timePerFrame)
    switch dinosaurType {
    case .stegosaurus:
      super.init(texture: eastIdleTextures[0], color: UIColor.black, size: eastIdleTextures[0].size())
      setState(dinosaurState: .idle, direction: .east)
    case .raptor:
      super.init(texture: westRunTextures[0], color: UIColor.black, size: westRunTextures[0].size())
      setState(dinosaurState: .run, direction: .west)
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setState(dinosaurState: DinosaurState, direction: Direction) {
//    removeAllActions()
    
//    func startZombieAnimation() {
//      if zombie.actionForKey("animation") == nil {
//        zombie.runAction(
//          SKAction.repeatActionForever(zombieAnimation),
//          withKey: "animation")
//      }
//    }
//    
//    func stopZombieAnimation() {
//      zombie.removeActionForKey("animation")
//    }
    
//    state = dinosaurState
//    self.direction = direction
//    switch state {
//    case .idle:
//      runAction(SKAction.repeatActionForever(direction == .east || direction == .northeast || direction == .southeast || direction == .north ? eastIdleAnimation : westIdleAnimation))
//    case .walk:
//      runAction(SKAction.repeatActionForever(direction == .east || direction == .northeast || direction == .southeast || direction == .north ? eastWalkAnimation : westWalkAnimation))
//    case .dead:
//      runAction(direction == .east || direction == .northeast || direction == .southeast || direction == .north ? eastDeadAnimation : westDeadAnimation)
//    }
    
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
  
//  func flip() {
//    let newState: DinosaurState
//    if state == .walk {
//      newState = .idle
//    }
//    else {
//      newState = .walk
//    }
//    switch direction {
//    case .east:
//      setState(dinosaurState: newState, direction: .west)
//    case .northeast:
//      setState(dinosaurState: newState, direction: .northwest)
//    case .southeast:
//      setState(dinosaurState: newState, direction: .southwest)
//    case .north:
//      setState(dinosaurState: newState, direction: .south)
//    case .west:
//      setState(dinosaurState: newState, direction: .east)
//    case .southwest:
//      setState(dinosaurState: newState, direction: .southeast)
//    case .northwest:
//      setState(dinosaurState: newState, direction: .northwest)
//    case .south:
//      setState(dinosaurState: newState, direction: .north)
//    case .center:
//      setState(dinosaurState: newState, direction: .east)
//    case .error:
//      fatalError("invalid direction")
//    }
//  }
}
