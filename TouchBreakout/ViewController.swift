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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.styleMask.remove(NSWindow.StyleMask.resizable)
    }
    
    @objc func restartGame() {
        gameScene?.gameState = .new
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .touchBar
        touchBar.defaultItemIdentifiers = [.touchEvent]
        touchBar.customizationAllowedItemIdentifiers = [.touchEvent]
        return touchBar
    }
    
}

@available(OSX 10.12.2, *)
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

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let touchBar = NSTouchBar.CustomizationIdentifier(rawValue: "com.krayc.touchBreakoutBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let touchEvent = NSTouchBarItem.Identifier("com.krayc.touchEvent")
}
