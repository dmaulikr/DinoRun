//
//  GameScene.swift
//  DinoRun
//
//  Created by Joshua Adams on 9/27/16.
//  Copyright (c) 2016 Josh Adams. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  let player = SKSpriteNode(imageNamed: "eIdle1")
  let cameraNode = SKCameraNode()
  let playableRect: CGRect
  let playerRotateRadiansPerSec:CGFloat = 4.0 * π
  let playerMovePointsPerSec: CGFloat = 700.0
  let eggMovePointsPerSec: CGFloat = 700.0
  let playerIdleAnimation: SKAction
  let playerWalkingAnimation: SKAction
  let enemyRunningAnimation: SKAction
  let roarSound: SKAction = SKAction.playSoundFileNamed("roar.mp3", waitForCompletion: false)
  let cameraMovePointsPerSec: CGFloat = 200.0
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
  var velocity = CGPoint.zero
  var lastTouchLocation: CGPoint?
  var idling = true
  var playerIsInvincible = false
  var lives = 5
  var gameOver = false
  
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    var textures:[SKTexture] = []
    for i in 1...10 {
      textures.append(SKTexture(imageNamed: "eIdle\(i)"))
    }
    playerIdleAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
    textures = []
    for i in 1...10 {
      textures.append(SKTexture(imageNamed: "eWalk\(i)"))
    }
    playerWalkingAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
    textures = []
    for i in 1...8 {
      textures.append(SKTexture(imageNamed: "wRun\(i)"))
    }
    enemyRunningAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
    super.init(size: size)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    playBackgroundMusic("backgroundMusic.mp3")
    backgroundColor = SKColor.black
    for i in 0...2 {
      let background = backgroundNode()
      background.anchorPoint = CGPoint.zero
      background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
      background.name = "background"
      addChild(background)
    }
    player.position = CGPoint(x: 400, y: 400)
    player.xScale = 0.5
    player.yScale = 0.5
    player.zPosition = 100.0
    addChild(player)
    player.run(SKAction.repeatForever(playerIdleAnimation))
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemy), SKAction.wait(forDuration: 2.0)])))
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEgg), SKAction.wait(forDuration: 1.0)])))
    addChild(cameraNode)
    camera = cameraNode
    //cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
    setCameraPosition(position: CGPoint(x: size.width/2, y: size.height/2))
  }
  
  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
//    if let lastTouchLocation = lastTouchLocation {
//      let diff = lastTouchLocation - player.position
//      if (diff.length() <= playerMovePointsPerSec * CGFloat(dt)) {
//        player.position = lastTouchLocation
//        velocity = CGPoint.zero
//      } else {
        moveSprite(player, velocity: velocity)
        rotateSprite(player, direction: velocity, rotateRadiansPerSec: playerRotateRadiansPerSec)
//      }
//    }
    boundsCheckPlayer()
    if !idling && velocity == CGPoint.zero {
      idling = true
      player.removeAction(forKey: "walking")
      player.run(SKAction.repeatForever(playerIdleAnimation), withKey: "idle")
    }
    moveTrain()
    moveCamera()
    if lives <= 0 && !gameOver {
      gameOver = true
      print("You lose!")
      backgroundMusicPlayer.stop()
      let gameOverScene = GameOverScene(size: size, won: false)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)
    }
    //cameraNode.position = player.position
  }
  
  override func didEvaluateActions()  {
    checkCollisions()
  }
  
  func moveTrain() {
    var trainCount = 0
    var targetPosition = player.position
    enumerateChildNodes(withName: "train") { node, stop in
      trainCount += 1
      if !node.hasActions() {
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.eggMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
        node.run(moveAction)
      }
      targetPosition = node.position
    }
    if trainCount >= 10 && !gameOver {
      gameOver = true
      print("You win!")
      backgroundMusicPlayer.stop()
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)
    }
  }
  
  func moveSprite(_ sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
  }
  
  func movePlayerToward(_ location: CGPoint) {
    let offset = location - player.position
    let direction = offset.normalized()
    velocity = direction * playerMovePointsPerSec
  }
  
  func boundsCheckPlayer() {
    let bottomLeft = CGPoint(x: cameraRect.minX,
                             y: cameraRect.minY)
    let topRight = CGPoint(x: cameraRect.maxX,
                           y: cameraRect.maxY)
    if player.position.x >= topRight.x {
      player.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if player.position.y <= bottomLeft.y {
      player.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if player.position.y >= topRight.y {
      player.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
  
  func loseEggs() {
    var loseCount = 0
    enumerateChildNodes(withName: "train") { node, stop in
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.y += CGFloat.random(min: -100, max: 100)
      node.name = ""
      node.run(
        SKAction.sequence([
          SKAction.group([
            SKAction.rotate(byAngle: π*4, duration: 1.0),
            SKAction.move(to: randomSpot, duration: 1.0),
            SKAction.scale(to: 0, duration: 1.0)
            ]),
          SKAction.removeFromParent()
          ]))
      loseCount += 1
      if loseCount >= 2 {
        stop[0] = true
      }
    }
  }
  
  func sceneTouched(_ touchLocation: CGPoint) {
    lastTouchLocation = touchLocation
    movePlayerToward(touchLocation)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation)
    player.removeAction(forKey: "walking")
    player.removeAction(forKey: "idle")
    player.run(SKAction.repeatForever(playerWalkingAnimation), withKey: "walking")
    idling = false
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation)
  }
  
  func rotateSprite(_ sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate
  }
  
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    enemy.xScale = 0.7
    enemy.yScale = 0.7
    enemy.position = CGPoint(
      x: cameraRect.maxX + enemy.size.width/2,
      y: CGFloat.random(
        min: cameraRect.minY + enemy.size.height/2,
        max: cameraRect.maxY - enemy.size.height/2))
    enemy.zPosition = 50
    addChild(enemy)
    enemy.run(SKAction.repeatForever(enemyRunningAnimation))
    let actionMove = SKAction.moveBy(x: -size.width-enemy.size.width*2, y: 0, duration: 3.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))

  }
  
  func spawnEgg() {
    let egg = SKSpriteNode(imageNamed: "egg")
    egg.name = "egg"
    egg.position = CGPoint(
      x: CGFloat.random(min: cameraRect.minX,
                        max: cameraRect.maxX),
      y: CGFloat.random(min: cameraRect.minY,
                        max: cameraRect.maxY))
    egg.zPosition = 50
    egg.setScale(0)
    addChild(egg)
    let appear = SKAction.scale(to: 0.4, duration: 0.5)
    egg.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversed()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
    let scaleDown = scaleUp.reversed()
    let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeat(group, count: 10)
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    egg.run(SKAction.sequence(actions))
  }
  
  func playerHitEgg(_ egg: SKSpriteNode) {
    egg.name = "train"
    egg.removeAllActions()
    egg.xScale = 0.4
    egg.yScale = 0.4
    egg.zRotation = 0.0
    egg.run(SKAction.colorize(with: SKColor.blue, colorBlendFactor: 0.5, duration: 0.7))
  }
  
  func playerHitEnemy(_ enemy: SKSpriteNode) {
    playerIsInvincible = true
    run(roarSound)
    loseEggs()
    lives -= 1
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customAction(withDuration: duration) {
      node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }
    let setHidden = SKAction.run() {
      self.player.isHidden = false
      self.playerIsInvincible = false
    }
    player.run(SKAction.sequence([blinkAction, setHidden]))
  }
  
  func checkCollisions() {
    var hitEggs: [SKSpriteNode] = []
    enumerateChildNodes(withName: "egg") { node, _ in
      let egg = node as! SKSpriteNode
      if egg.frame.intersects(self.player.frame) {
        hitEggs.append(egg)
      }
    }
    for egg in hitEggs {
      playerHitEgg(egg)
    }
    if !playerIsInvincible {
      var hitEnemies: [SKSpriteNode] = []
      enumerateChildNodes(withName: "enemy") { node, _ in
        let enemy = node as! SKSpriteNode
        if node.frame.insetBy(dx: 20, dy: 20).intersects(
          self.player.frame) {
          hitEnemies.append(enemy)
        }
      }
      for enemy in hitEnemies {
        playerHitEnemy(enemy)
      }
    }
  }
  
  func backgroundNode() -> SKSpriteNode {
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPoint.zero
    backgroundNode.name = "background"
    let background1 = SKSpriteNode(imageNamed: "background1")
    background1.anchorPoint = CGPoint.zero
    background1.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(background1)
    let background2 = SKSpriteNode(imageNamed: "background2")
    background2.anchorPoint = CGPoint.zero
    background2.position =
      CGPoint(x: background1.size.width, y: 0)
    backgroundNode.addChild(background2)
    let background3 = SKSpriteNode(imageNamed: "background3")
    background3.anchorPoint = CGPoint.zero
    background3.position =
      CGPoint(x: background1.size.width * 2, y: 0)
    backgroundNode.addChild(background3)
    backgroundNode.size = CGSize(
      width: background1.size.width + background2.size.width + background3.size.width,
      height: background1.size.height)
    return backgroundNode
  }
  
  func overlapAmount() -> CGFloat {
    guard let view = self.view else {
      return 0 }
    let scale = view.bounds.size.width / self.size.width
    let scaledHeight = self.size.height * scale
    let scaledOverlap = scaledHeight - view.bounds.size.height
    return scaledOverlap / scale
  }
  
  func getCameraPosition() -> CGPoint {
    return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y +
      overlapAmount()/2)
  }
  
  func setCameraPosition(position: CGPoint) {
    cameraNode.position = CGPoint(x: position.x, y: position.y -
      overlapAmount()/2)
  }
  
  func moveCamera() {
    let backgroundVelocity =
      CGPoint(x: cameraMovePointsPerSec, y: 0)
    let amountToMove = backgroundVelocity * CGFloat(dt)
    cameraNode.position += amountToMove
    enumerateChildNodes(withName: "background") { node, _ in
      let background = node as! SKSpriteNode
      if background.position.x + background.size.width <
        self.cameraRect.origin.x {
        background.position = CGPoint(
          x: background.position.x + background.size.width*2,
          y: background.position.y)
      }
    }
  }
  
  var cameraRect : CGRect {
    return CGRect(
      x: getCameraPosition().x - size.width/2
        + (size.width - playableRect.width)/2,
      y: getCameraPosition().y - size.height/2
        + (size.height - playableRect.height)/2,
      width: playableRect.width,
      height: playableRect.height)
  }
}