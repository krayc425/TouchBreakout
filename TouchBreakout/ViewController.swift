//
//  ViewController.swift
//  TouchBreakout
//
//  Created by 宋 奎熹 on 2017/11/16.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                gameScene = scene as? GameScene
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        
        let restartButton = NSButton(image: #imageLiteral(resourceName: "restart"), target: self, action: #selector(restartGame))
        restartButton.frame = CGRect(x: 15, y: view.frame.height - 60, width: 45, height: 45)
        view.addSubview(restartButton)
    }
    
    @objc func restartGame() {
        gameScene?.gameState = .new
        
//        GameHelper.shared.setBestScore(score: 0)
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .touchBar
        touchBar.defaultItemIdentifiers = [.touchEvent]
        touchBar.customizationAllowedItemIdentifiers = [.touchEvent]
        return touchBar
    }
    
}

extension ViewController: NSTouchBarDelegate {
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let touchBarView = TouchBarView()
        touchBarView.wantsLayer = true
        touchBarView.layer?.backgroundColor = NSColor.clear.cgColor
        touchBarView.allowedTouchTypes = .direct
        
        touchBarView.delegate = gameScene
        
        let custom = NSCustomTouchBarItem(identifier: identifier)
        custom.view = touchBarView
        
        return custom
    }
    
}

fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let touchBar = NSTouchBar.CustomizationIdentifier.init(rawValue: "com.krayc.touchBreakoutBar")
}

fileprivate extension NSTouchBarItem.Identifier {
    static let touchEvent = NSTouchBarItem.Identifier("com.krayc.touchEvent")
}
