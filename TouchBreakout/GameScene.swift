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
    
    private let kLeftKeyCode    : UInt16 = 123
    private let kRightKeyCode   : UInt16 = 124
    
    private let kBasicBallSpeed = 30.0
    private var kBallSpeed      = 30.0
    private let kBallNodeName   = "Ball"
    private let kPaddleNodeName = "Paddle"
    private let kBlockNodeName  = "Block"
    private let kLabelNodeName  = "ScoreLabel"
    
    private let kBallCategory   : UInt32 = 0x1 << 0
    private let kBottomCategory : UInt32 = 0x1 << 1
    private let kBlockCategory  : UInt32 = 0x1 << 2
    private let kPaddleCategory : UInt32 = 0x1 << 3
    private let kBorderCategory : UInt32 = 0x1 << 4
    private let kHiddenCategory : UInt32 = 0x1 << 5
    
    private let kBlockWidth: CGFloat        = 100.0
    private let kBlockHeight: CGFloat       = 25.0
    private let kBlockRecoverTime: Double   = 5.0
    private let kBlockRows                  = 8
    private let kBlockColumns               = 8
    
    fileprivate var paddle: SKSpriteNode!
    fileprivate var ball: SKSpriteNode!
    
    fileprivate var scoreLabel: SKLabelNode!
    fileprivate var currentScore: Int = 0 {
        didSet {
            scoreLabel.text = "\(currentScore)"
        }
    }
    
    fileprivate var halfScreenWidth: CGFloat {
        return (scene?.size.width)! / 2
    }
    fileprivate var halfPaddleWidth: CGFloat {
        return (paddle?.size.width)! / 2
    }
    
    var touchBarDelegate: TouchBarViewDelegate?
    
    override func didMove(to view: SKView) {
        // Label
        scoreLabel = childNode(withName: kLabelNodeName) as! SKLabelNode
        // Border
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        // Ball
        ball = childNode(withName: kBallNodeName) as! SKSpriteNode
        ball.physicsBody!.applyImpulse(CGVector(dx: kBallSpeed, dy: kBallSpeed))
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        // Bottom
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        // Paddle
        paddle = childNode(withName: kPaddleNodeName) as! SKSpriteNode
        
        // BitMasks
        bottom.physicsBody!.categoryBitMask = kBottomCategory
        ball.physicsBody!.categoryBitMask   = kBallCategory
        paddle.physicsBody!.categoryBitMask = kPaddleCategory
        borderBody.categoryBitMask          = kBorderCategory
        
        ball.physicsBody!.contactTestBitMask = kBottomCategory | kBlockCategory
        
        // Blocks
        let totalBlocksWidth = kBlockWidth * CGFloat(kBlockColumns)
        let xOffset = -totalBlocksWidth / 2
        let yOffset = frame.height * 0.075
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
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case kLeftKeyCode:
            if (paddle?.position.x)! - halfPaddleWidth > -halfScreenWidth {
                paddle?.moveLeft()
            }
        case kRightKeyCode:
            if (paddle?.position.x)! + halfPaddleWidth < halfScreenWidth {
                paddle?.moveRight()
            }
        default:
            break
        }
    }
    
    func breakBlock(node: SKNode) {
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform.sks")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                         SKAction.removeFromParent()]))
        
        let anotherNode: SKSpriteNode = node as! SKSpriteNode
        node.removeFromParent()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + kBlockRecoverTime) {
            self.addChild(anotherNode)
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
            currentScore = 0
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
