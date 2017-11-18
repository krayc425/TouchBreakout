//
//  GameScene.swift
//  TouchBreakout
//
//  Created by 宋 奎熹 on 2017/11/16.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameState: GameState = .new {
        didSet {
            switch gameState {
            case .new:
                resetGame()
            default:
                break
            }
        }
    }
    
    private let kLeftKeyCode    : UInt16 = 123
    private let kRightKeyCode   : UInt16 = 124
    private let kSpaceKeyCode   : UInt16 = 49
    
    private let kBasicBallSpeed           = 30.0
    private var kBallSpeed                = 30.0
    private var kBallRadius     : CGFloat = 12.0
    
    private let kBallNodeName   = "Ball"
    private let kPaddleNodeName = "Paddle"
    private let kBlockNodeName  = "Block"
    private let kScoreNodeName  = "ScoreLabel"
    private let kBestNodeName   = "BestLabel"
    
    private let kBallCategory   : UInt32 = 0x1 << 0
    private let kBottomCategory : UInt32 = 0x1 << 1
    private let kBlockCategory  : UInt32 = 0x1 << 2
    private let kPaddleCategory : UInt32 = 0x1 << 3
    private let kBorderCategory : UInt32 = 0x1 << 4
    private let kHiddenCategory : UInt32 = 0x1 << 5
    
    private let kBlockWidth: CGFloat        = 90.0
    private let kBlockHeight: CGFloat       = 25.0
    private let kBlockRows                  = 8
    private let kBlockColumns               = 8
    private var kBlockRecoverTime           = 10.0
    
    private var velocityDx: CGFloat = 0.0
    private var velocityDy: CGFloat = 0.0
    
    fileprivate var paddle: SKSpriteNode!
    fileprivate var ball: SKSpriteNode!
    fileprivate var bestLabel: SKLabelNode!
    fileprivate var scoreLabel: SKLabelNode!
    fileprivate var currentScore: Int = 0 {
        didSet {
            scoreLabel.text = "\(currentScore)"
            if currentScore > GameHelper.shared.loadBestScore() {
                GameHelper.shared.setBestScore(score: currentScore)
                bestLabel.text = "Best: \(currentScore)"
            }
            
//            if currentScore > 0 {
//                velocityDx += 1
//                velocityDy += 1
//            }
            
//            print(velocityDx, velocityDy)
            
//            ball.physicsBody?.velocity = CGVector(dx: velocityDx, dy: velocityDy)
        }
    }
    
    fileprivate var halfScreenWidth: CGFloat {
        return (scene?.size.width)! / 2
    }
    fileprivate var halfPaddleWidth: CGFloat {
        return (paddle?.size.width)! / 2
    }
    
    private var removedBlocks = Set<SKSpriteNode>()
    
    var touchBarDelegate: TouchBarViewDelegate?
    
    // MARK: - Game Manager
    
    private func resetGame() {
        scoreLabel.text = "Press any key to start"
        scoreLabel.fontSize = 100.0
        ball.run(SKAction.move(to: CGPoint(x: 0.0, y: -150.0), duration: 0.0))
        ball.physicsBody?.velocity = .zero
        velocityDx = CGFloat(kBallSpeed)
        velocityDy = CGFloat(kBallSpeed)
        removedBlocks.forEach { self.addChild($0) }
        removedBlocks.removeAll()
    }
    
    private func startGame(){
        currentScore = 0
        scoreLabel.fontSize = 150.0
        ball.physicsBody!.applyImpulse(CGVector(dx: kBallSpeed, dy: kBallSpeed))
    }
    
    private func pauseGame() {
        if gameState == .running {
            velocityDx = ball.physicsBody?.velocity.dx ?? CGFloat(kBallSpeed)
            velocityDy = ball.physicsBody?.velocity.dy ?? CGFloat(kBallSpeed)
            ball.physicsBody?.velocity = .zero
            gameState = .paused
        }
    }
    
    private func continueGame() {
        if gameState == .paused {
            ball.physicsBody?.velocity = CGVector(dx: velocityDx, dy: velocityDy)
            gameState = .running
        }
    }
    
    override func didMove(to view: SKView) {
        // Label
        scoreLabel = childNode(withName: kScoreNodeName) as! SKLabelNode
        bestLabel = childNode(withName: kBestNodeName) as! SKLabelNode
        bestLabel.text = "Best: \(GameHelper.shared.loadBestScore())"
        // Border
        let rectPath = CGPath(rect: self.frame, transform: nil)
        let borderBody = SKPhysicsBody(edgeLoopFrom: rectPath)
        view.frame = rectPath.boundingBoxOfPath
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.usesPreciseCollisionDetection = true
        self.physicsBody = borderBody
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        // Ball
        ball = childNode(withName: kBallNodeName) as! SKSpriteNode
        ball.physicsBody?.usesPreciseCollisionDetection = true
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        // Bottom
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: kBallRadius)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        // Paddle
        paddle = childNode(withName: kPaddleNodeName) as! SKSpriteNode
        
        // Blocks
        let totalBlocksWidth = kBlockWidth * CGFloat(kBlockColumns)
        let xOffset = -totalBlocksWidth / 2
        let yOffset = frame.height * 0.1
        for i in 0..<kBlockRows {
            for j in 0..<kBlockColumns {
                let block = SKSpriteNode(color: NSColor.blockColors()[(i + j + 1) % kBlockColumns],
                                         size: CGSize(width: kBlockWidth, height: kBlockHeight))
                block.position = CGPoint(x: xOffset + CGFloat(CGFloat(j) + 0.5) * kBlockWidth,
                                         y: yOffset + CGFloat(CGFloat(i) + 0.5) * kBlockHeight)
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = kBlockNodeName
                block.physicsBody!.categoryBitMask = kBlockCategory
                block.zPosition = 2
                addChild(block)
            }
        }
        
        // BitMasks
        bottom.physicsBody!.categoryBitMask = kBottomCategory
        ball.physicsBody!.categoryBitMask   = kBallCategory
        paddle.physicsBody!.categoryBitMask = kPaddleCategory
        borderBody.categoryBitMask          = kBorderCategory
        ball.physicsBody!.contactTestBitMask = kBottomCategory | kBlockCategory
        
        childNode(withName: "Corners")?.children.forEach {
            $0.physicsBody?.categoryBitMask = kBorderCategory
        }
        
        resetGame()
    }
    
    // MARK: - Event Handler
    
    override func keyDown(with event: NSEvent) {
        switch gameState {
        case .new:
            gameState = .running
            startGame()
        case .paused:
            if event.keyCode == kSpaceKeyCode {
                continueGame()
            } else {
                break
            }
        case .running:
            switch event.keyCode {
            case kLeftKeyCode:
                if (paddle?.position.x)! > -halfScreenWidth + 2 * halfPaddleWidth {
                    paddle?.moveLeft()
                }
            case kRightKeyCode:
                if (paddle?.position.x)! < halfScreenWidth - 2 * halfPaddleWidth {
                    paddle?.moveRight()
                }
            case kSpaceKeyCode:
                pauseGame()
            default:
                break
            }
        }
    }
    
    private func breakBlock(node: SKNode) {
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform.sks")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                         SKAction.removeFromParent()]))
        let anotherNode: SKSpriteNode = node as! SKSpriteNode
        node.removeFromParent()
        removedBlocks.insert(anotherNode)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + kBlockRecoverTime) {
            if self.removedBlocks.contains(anotherNode) {
                self.removedBlocks.remove(anotherNode)
                self.addChild(anotherNode)
            }
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kBottomCategory {
            gameState = .new
            return
        }
        
        if firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kBlockCategory {
            breakBlock(node: secondBody.node!)
            currentScore += 1
        }
    }
    
}

extension GameScene: TouchBarViewDelegate {
    
    func didMoveTo(_ locationX: Double) {
        var transformedX = CGFloat(locationX) / 600.0 * (scene?.size.width)! - (scene?.size.width)! / 2
        if transformedX - halfPaddleWidth < -halfScreenWidth {
            transformedX = -halfScreenWidth + halfPaddleWidth
        }
        if transformedX + halfPaddleWidth > halfScreenWidth {
            transformedX = halfScreenWidth - halfPaddleWidth
        }
        paddle?.moveTo(x: transformedX)
    }
    
}
