//
//  GameScene.swift
//  DinoRun
//
//  Created by Joshua Adams on 9/27/16.
//  Copyright (c) 2016 Josh Adams. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  let player = Dinosaur(dinosaurType: .stegosaurus)
  let cameraNode = SKCameraNode()
  let playableRect: CGRect
  let playerRotateRadiansPerSec:CGFloat = 4.0 * π
  let playerMovePointsPerSec: CGFloat = 300.0
  let eggMovePointsPerSec: CGFloat = 300.0
  let roarSound: SKAction = SKAction.playSoundFileNamed("roar.mp3", waitForCompletion: false)
  let livesLabel = SKLabelNode(fontNamed: Font.chalkboard.rawValue)
  let container = SKSpriteNode(imageNamed: "container")
  let controller = SKSpriteNode(imageNamed: "controller")
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
  var velocity = CGPoint.zero
  var lastTouchLocation: CGPoint?
  var idling = true
  var playerIsInvincible = false
  var lives = 5
  var gameOver = false
  var shouldScrollRight = false
  var shouldScrollLeft = false
  var panGeRec: UIPanGestureRecognizer!
  var containerWidthAndHeight: CGFloat!
  var controllerMoving = false
  var controllerPosition: CGPoint!
  var currentDirection = Direction()

  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    var textures:[SKTexture] = []
    for i in 1...8 {
      textures.append(SKTexture(imageNamed: "wRun\(i)"))
    }
    super.init(size: size)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    scene?.scaleMode = .aspectFill
    playBackgroundMusic("backgroundMusic.mp3") // currently "Shenyang" by Kevin MacCleod
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
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemy), SKAction.wait(forDuration: 2.0)])))
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEgg), SKAction.wait(forDuration: 1.0)])))
    addChild(cameraNode)
    camera = cameraNode
    
    container.xScale = 3.0
    container.yScale = 3.0
    controller.xScale = 3.0
    controller.yScale = 3.0
    containerWidthAndHeight = container.size.width
    controllerPosition = CGPoint(x: containerWidthAndHeight, y: view.frame.size.height)
    container.position = controllerPosition
    container.zPosition = 1.0
    addChild(container)
    controller.zPosition = 2.0
    controller.position = controllerPosition
    addChild(controller)
    panGeRec = UIPanGestureRecognizer(target: self, action: #selector(GameScene.handlePan(_:)))
    view.addGestureRecognizer(panGeRec)
    setCameraPosition(position: CGPoint(x: size.width/2, y: size.height/2))
    livesLabel.text = "Lives: X"
    livesLabel.fontColor = SKColor.black
    livesLabel.fontSize = 100
    livesLabel.zPosition = 100
    livesLabel.horizontalAlignmentMode = .left
    livesLabel.verticalAlignmentMode = .bottom
    livesLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20),
                                  y: -playableRect.size.height/2 - CGFloat(160) + overlapAmount() / 2)
      cameraNode.addChild(livesLabel)
    UIFont.familyNames.map {UIFont.fontNames(forFamilyName: $0)}.forEach {(n:[String]) in n.forEach {print($0)}}
  }
  
  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    moveTrain()
    moveCamera()
    if lives <= 0 && !gameOver {
      gameOver = true
      backgroundMusicPlayer.stop()
      let gameOverScene = GameOverScene(size: size, won: false)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)
    }
    
    if controllerMoving {
      let scrollBuffer: CGFloat = player.size.width / 1.5
      if player.position.x >= cameraRect.maxX - scrollBuffer && (currentDirection == .east || currentDirection == .northeast || currentDirection == .southeast) {
        shouldScrollRight = true
      }
      else if player.position.x <= cameraRect.minX + scrollBuffer && (currentDirection == .west || currentDirection == .northwest || currentDirection == .southwest) {
        shouldScrollLeft = true
      }
      let playerDelta: CGFloat = CGFloat(dt) * playerMovePointsPerSec
      var yDelta = playerDelta
      let limitMultiplier: CGFloat = 0.67
      let bottomLimit = player.size.height * limitMultiplier
      let topLimit = cameraRect.maxY - player.size.height / limitMultiplier
      switch(currentDirection) {
      case .error:
        fatalError("Erroneous direction.")
      case .center:
        break
      case .east:
        player.position = CGPoint(x: player.position.x + playerDelta, y: player.position.y)
        shouldScrollLeft = false
      case .northeast:
        if player.position.y > topLimit {
          yDelta = 0.0
        }
        player.position = CGPoint(x: player.position.x + playerDelta, y: player.position.y + yDelta)
        shouldScrollLeft = false
      case .north:
        if player.position.y > topLimit {
          yDelta = 0.0
        }
        player.position = CGPoint(x: player.position.x, y: player.position.y + yDelta)
        shouldScrollRight = false
        shouldScrollLeft = false
      case .northwest:
        if player.position.y > topLimit {
          yDelta = 0.0
        }
        player.position = CGPoint(x: player.position.x - playerDelta, y: player.position.y + yDelta)
        shouldScrollRight = false
      case .west:
        player.position = CGPoint(x: player.position.x - playerDelta, y: player.position.y)
        shouldScrollRight = false
      case .southwest:
        if player.position.y < bottomLimit {
          yDelta = 0.0
        }
        player.position = CGPoint(x: player.position.x - playerDelta, y: player.position.y - yDelta)
        shouldScrollRight = false
      case .south:
        if player.position.y < bottomLimit {
          yDelta = 0.0
        }
        player.position = CGPoint(x: player.position.x, y: player.position.y - yDelta)
        shouldScrollRight = false
        shouldScrollLeft = false
      case .southeast:
        if player.position.y < bottomLimit {
          yDelta = 0.0
        }
        player.position = CGPoint(x: player.position.x + playerDelta, y: player.position.y - yDelta)
        shouldScrollLeft = false
      }
    }
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
      backgroundMusicPlayer.stop()
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      view?.presentScene(gameOverScene, transition: reveal)
    }
    livesLabel.text = "Lives: \(lives)"
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
  
  func spawnEnemy() {
    let enemy = Dinosaur(dinosaurType: .raptor)
    enemy.setState(dinosaurState: .run, direction: .west)
    enemy.name = "enemy"
    enemy.xScale = 0.3
    enemy.yScale = 0.3
    enemy.position = CGPoint(
      x: cameraRect.maxX + enemy.size.width / 2,
      y: CGFloat.random(min: cameraRect.minY + enemy.size.height / 2, max: cameraRect.maxY - enemy.size.height/2))
    enemy.zPosition = 50
    addChild(enemy)
    let enemyMoveDuration: TimeInterval = 7.0
    let screensToMove: CGFloat = 3.0
    let actionMove = SKAction.moveBy(x: -size.width * screensToMove, y: 0, duration: enemyMoveDuration * TimeInterval(screensToMove))
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
  }
  
  func spawnEgg() {
    let egg = SKSpriteNode(imageNamed: "egg")
    egg.name = "egg"
    egg.position = CGPoint(x: CGFloat.random(min: cameraRect.minX, max: cameraRect.maxX),
                           y: CGFloat.random(min: cameraRect.minY, max: cameraRect.maxY))
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
        if node.frame.insetBy(dx: 20, dy: 20).intersects(self.player.frame) {
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
    background2.position = CGPoint(x: background1.size.width, y: 0)
    backgroundNode.addChild(background2)
    let background3 = SKSpriteNode(imageNamed: "background3")
    background3.anchorPoint = CGPoint.zero
    background3.position = CGPoint(x: background1.size.width * 2, y: 0)
    backgroundNode.addChild(background3)
    backgroundNode.size = CGSize(width: background1.size.width + background2.size.width + background3.size.width, height: background1.size.height)
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
    if shouldScrollRight {
      let backgroundVelocity = CGPoint(x: playerMovePointsPerSec, y: 0)
      let amountToMove = backgroundVelocity * CGFloat(dt)
      cameraNode.position += amountToMove
      controller.position += amountToMove
      container.position += amountToMove
      controllerPosition = container.position
      enumerateChildNodes(withName: "background") { node, _ in
        let background = node as! SKSpriteNode
        if background.position.x + background.size.width < self.cameraRect.origin.x {
          background.position = CGPoint(x: background.position.x + background.size.width * 3, y: background.position.y)
        }
      }
    }
    else if shouldScrollLeft {
      let backgroundVelocity = CGPoint(x: playerMovePointsPerSec, y: 0)
      let amountToMove = backgroundVelocity * CGFloat(dt)
      cameraNode.position -= amountToMove
      controller.position -= amountToMove
      container.position -= amountToMove
      controllerPosition = container.position
      enumerateChildNodes(withName: "background") { node, _ in
        let background = node as! SKSpriteNode
        if background.position.x - background.size.width > self.cameraRect.origin.x {
          background.position = CGPoint(x: background.position.x - background.size.width * 3, y: background.position.y)
        }
      }
    }
  }
  
  var cameraRect : CGRect {
    return CGRect(
      x: getCameraPosition().x - size.width/2 + (size.width - playableRect.width)/2,
      y: getCameraPosition().y - size.height/2 + (size.height - playableRect.height)/2,
      width: playableRect.width, height: playableRect.height)
  }
  
  @IBAction func handlePan(_ recognizer:UIPanGestureRecognizer) {
    let location = recognizer.location(in: view)
    let locationInScene = (scene?.convertPoint(fromView: location))!
    let distanceFromControllerPosition = controllerPosition.distance(locationInScene)
    if distanceFromControllerPosition < 120 {
      controller.position = locationInScene
      let p1 = CGPoint(x: controllerPosition.x + distanceFromControllerPosition, y: controllerPosition.y)
      let p2 = locationInScene
      let v1 = CGVector(dx: p1.x - controllerPosition.x, dy: p1.y - controllerPosition.y)
      let v2 = CGVector(dx: p2.x - controllerPosition.x, dy: p2.y - controllerPosition.y)
      let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
      var degrees = angle * CGFloat(180.0 / M_PI)
      if degrees < 0 {
        degrees += 360.0
      }
      currentDirection.setDirection(degrees)
    }
    
    switch(recognizer.state) {
    case .began, .changed:
      controllerMoving = true
      player.setState(dinosaurState: .walk, direction: currentDirection)
    case .ended, .cancelled, .failed:
      controllerMoving = false
      shouldScrollRight = false
      shouldScrollLeft = false
      player.setState(dinosaurState: .idle, direction: currentDirection)
      controller.run(SKAction.move(to: controllerPosition, duration: 0.3))
      currentDirection = .center
    case .possible:
      fatalError("invalid gesture state")
    }
  }
}
