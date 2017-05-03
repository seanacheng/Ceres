//
//  LeaderBoardScene.swift
//  Ceres
//
//  Created by Sean Cheng on 5/3/17.
//  Copyright © 2017 Stellanova. All rights reserved.
//

import Foundation
import SpriteKit

class LeaderBoardScene: SKScene {
    
    let title = "Leaderboard"
    let titleNode = SKLabelNode(fontNamed: "Menlo-Bold")
    
    var backButton = SKSpriteNode()
    let backButtonTex = SKTexture(imageNamed: "back")
    
    var starfield:SKEmitterNode!
    
    let swipeRightRec = UISwipeGestureRecognizer()
    
    let defaultsManager = DefaultsManager()
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        
        titleNode.text = title
        titleNode.fontSize = 32
        titleNode.fontColor = SKColor.white
        titleNode.position = RelativePositions.Title.getAbsolutePosition(size: size)
        addChild(titleNode)
        
        backButton = SKSpriteNode(texture: backButtonTex)
        //        backButton.setScale(0.175)
        let backButtonSize = RelativeScales.BackButton.getAbsoluteSize(screenSize: size, nodeSize: backButton.size)
        backButton.xScale = backButtonSize.width
        backButton.yScale = backButtonSize.height
        backButton.position = RelativePositions.BackButton.getAbsolutePosition(size: size)
        addChild(backButton)
        
        starfield = SKEmitterNode(fileNamed: "starShower")
        starfield.position = RelativePositions.Starfield.getAbsolutePosition(size: size)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = -1
        
        swipeRightRec.addTarget(self, action: #selector(SettingsScene.swipedRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        showScores()
    }
    
    
    private func showScores(){
        //Presents the top scores 
        
        let highScores = defaultsManager.presentHighScores()
        
        for i in 0...(highScores.count - 1) {
            let highScore = SKLabelNode(fontNamed: "Menlo-Bold")
            highScore.text = "\((i + 1)). \(highScores[i])"
            highScore.fontSize = 28
            highScore.fontColor = SKColor.white
            highScore.position = RelativePositions.HighScoresLabel.getAbsolutePosition(size: size, constantY: (-PositionConstants.leaderBoardScoresDistance * CGFloat(i)))
            addChild(highScore)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //looks for a touch
        if let touch = touches.first{
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            //transitions back to menu screen if back button is touched
            if node == backButton {
                if view != nil {
                    transitionHome()
                }
            }
        }
    }
    
    
    func swipedRight() {
        transitionHome()
    }
    
    private func transitionHome() {
        let transition:SKTransition = SKTransition.push(with: .right, duration: 1)
        let scene:SKScene = MenuScene(size: self.size)
        self.view?.presentScene(scene, transition: transition)
    }

    
}
