//
//  GameScene+Gameplay.swift
//  Ceres
//
//  Created by Steven Roach on 4/14/17.
//  Copyright © 2017 Stellanova. All rights reserved.
//

import SpriteKit
import Foundation
import AudioToolbox.AudioServices

extension GameScene { // Gameplay
    
    
    public func beginGameplay() {
        // Adjust gravity of scene
        physicsWorld.gravity = CGVector(dx: 0, dy: 0.27) // Gravity on Ceres is 0.27 m/s²
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(animateLeftHammer),
                SKAction.wait(forDuration: 0.35),
                SKAction.run(animateRightHammer),
                SKAction.wait(forDuration: 0.35),
                ])
        ))
        
        run(SKAction.repeatForever( // Serves as timer, Could potentially refactor to use group actions later.
            SKAction.sequence([
                SKAction.run(spawnGems),
                SKAction.wait(forDuration: 1.0),
                SKAction.run(incrementTimer),
                ])
        ))
    }
    
    public func gemDidCollideWithCollector(gem: SKSpriteNode, collector: SKSpriteNode) {
        // Removes gem from game scene and increments number of gems collected
        gemsPlusMinus += 1
        recolorScore()
        collectGemAnimation(collector: collector)
        gem.removeFromParent()
        
        
    }
    
    public func detonatorGemDidCollideWithCollector(gem: SKSpriteNode, collector: SKSpriteNode) {
        // Removes gem from game scene and increments number of gems collected
        
        let shakeCollector = shakeAction(positionX: gemCollectorPosX)
        collectGemAnimation(collector: collector)
        
        collector.run(shakeCollector)
        run(collectorExplosionSound)
        
        let shakeScore = shakeAction(positionX: scoreLabel.position.x)
        scoreLabel.run(shakeScore)
        minusAlert(text: "-5")
        recolorScore()
        gemsPlusMinus -= 5

        gem.removeFromParent()
        checkGameOver()
    }
    
    public func gemOffScreen(gem: SKSpriteNode) {
        // Removes gems from game scene when they fly off screen
        gemsPlusMinus -= 1
        recolorScore()
        gem.removeFromParent()
        minusAlert(text: "-1")
        checkGameOver()
    }
    
    public func onLeftGemSourceTouch() {
        if !isPaused && !tutorialMode {
            addGemLeft()
            run(gemCreatedSound)
        }
    }
    
    public func onRightGemSourceTouch() {
        if !isPaused && !tutorialMode {
            addGemRight()
            run(gemCreatedSound)
        }
    }
    
    private func incrementTimer() {
        timerSeconds += 1
        if (timerSeconds % 10 >= 7){
            timerLabel.fontSize += 1
            run(zoomTimerSound)
        } else if (timerSeconds % 10 == 0 && timerSeconds > 0){
            run(zipTimerSound)
            timerLabel.fontSize -= 3
            timerLabel.fontColor = SKColor.cyan
        } else {
            timerLabel.fontColor = SKColor.white
        }
    }
    
    private func checkGameOver() {
        // Calculates score to figure out when to end the game
        if gemsPlusMinus <= losingGemPlusMinus {
            gameOverTransition()
        }
    }
    
    private func gameOverTransition() {
        isPaused = true
        if view != nil {
            let transition:SKTransition = SKTransition.fade(withDuration: 1)
            let scene = GameOverScene(size: size)
            scene.setScore(score: timerSeconds)
            view?.presentScene(scene, transition: transition)
        }
        removeAllActions()
    }
    
    
    private func spawnGems() { // TODO: Possibly refactor so that gamSpawn Sequences are in a sequence instead of being called based on the timerSeconds value.
        // Called every second, calls gem spawning sequences based on game timer
        if timerSeconds % 10 == 0 {
            switch timerSeconds {
            case 0:
                gemSpawnSequence1()
            case 10:
                gemSpawnSequence2()
            case 20:
                gemSpawnSequenceBasicDetonators()
            case 30:
                gemSpawnSequence3()
            case 40:
                gemSpawnSequence4()
            case 50:
                gemSpawnSequence4()
            case 60:
                gemSpawnSequence3()
            default:
                gemSpawnSequenceHard()
            }
        }
    }
    
    private func gemSpawnSequence1() {
        // Gem spawning routine
        run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run(addGemLeft), SKAction.wait(forDuration: 1.0), SKAction.run(addGemRight)]), count: 5))
    }
    
    private func gemSpawnSequence2() {
        // Gem spawning routine
        run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.25),
                                               SKAction.run(addGemRight),
                                               ]),
                            count: 8))
    }
    
    private func gemSpawnSequence3() {
        // Gem spawning routine
        run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.25),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               SKAction.wait(forDuration: 0.25),
                                               SKAction.run(addGemLeft),
                                               SKAction.run(addGemRight),
                                               
                                               ]),
                            count: 7))
    }
    
    private func gemSpawnSequence4() {
        run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 2.47),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               
                                               SKAction.wait(forDuration: 2.47),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemLeft),
                                               ]),
                            count: 2))
    }
    
    private func gemSpawnSequenceBasicDetonators() {
        run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 2.47),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               
                                               
                                               SKAction.wait(forDuration: 2.47),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               ]),
                            count: 2))
    }
    
    private func gemSpawnSequenceHard() {
        run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 0.74),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               
                                               SKAction.wait(forDuration: 0.2),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemLeft),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemLeft),
                                               SKAction.run(addGemRight),
                                               SKAction.run({self.detonateGemSequence(timeToExplosion: 2.0)}),
                                               SKAction.wait(forDuration: 0.01),
                                               SKAction.run(addGemLeft),
                                               ]),
                            count: 10))
    }
    
    // TODO: Refactor to make addGem one method that takes a parameter to change the spawning location
    private func addGemLeft() {
        // Produces a Gem from the left astronaut
        let gem = Gem(imageNamed: "gemShape1")
        gem.setGemProperties()  // Calls gem properties from Gem class
        let angle = random(min: CGFloat.pi * (1/4), max: CGFloat.pi * (1/2))
        let velocity = random(min: 170, max: 190)
        gem.setGemVelocity(velocity: velocity, angle: angle)
        gem.position = CGPoint(x: size.width * 0.15, y: size.height * 0.15)
        addChild(gem)
    }
    
    private func addGemRight() {
        // Produces a Gem from the right astronaut
        let gem = Gem(imageNamed: "gemShape1")
        gem.setGemProperties()  // Calls gem properties from Gem class
        let angle = random(min: CGFloat.pi * (1/2), max: CGFloat.pi * (3/4))
        let velocity = random(min: 170, max: 190)
        gem.setGemVelocity(velocity: velocity, angle: angle)
        gem.position = CGPoint(x: size.width * 0.85, y: size.height * 0.15)
        addChild(gem)
    }
    
    private func addDetonatorGem(detonatorGem: Gem) { // TODO: Refactor this to take a parameter for left and right.
        // Takes a gem and adds it to the scene in a manner specific to detonator gems
        detonatorGem.setGemProperties()  // Sets gem properties from Gem class
        detonatorGem.name = "detonatorGem"
        let angle = random(min: CGFloat.pi * (1/4), max: CGFloat.pi * (3/8))
        let velocity = random(min: 100, max: 120)
        detonatorGem.setGemVelocity(velocity: velocity, angle: angle)
        let spawnLocation = CGPoint(x: size.width * 0.15, y: size.height * 0.15)
        detonatorGem.position = spawnLocation
        addChild(detonatorGem)
    }
    
    private func flashDetonatorGemAnimation(duration: Double) -> SKAction {
        // Takes an animation duration and returns an animation to flash a detonator gem once
        let flashAction = SKAction.setTexture(SKTexture(imageNamed: "mostlyWhiteRottenGem"))
        let unFlashAction = SKAction.setTexture(SKTexture(imageNamed: "rottenGem"))
        
        let flashAnimation = SKAction.sequence([
            flashAction,
            SKAction.wait(forDuration: duration / 2),
            unFlashAction,
            SKAction.wait(forDuration: duration / 2)
            ])
        return flashAnimation
    }
    
    private func animateDetonatorGem(detonatorGem: Gem) {
        // Takes a detonatorGem and runs a flashing animation on it
        let flashDuration = 0.25
        detonatorGem.run(SKAction.repeat(SKAction.sequence([
            {self.flashDetonatorGemAnimation(duration: flashDuration)}(),
            ]), count: 20))
    }
    
    private func detonateGem(detonatorGem: Gem, gravityFieldNode: SKFieldNode) {
        // Takes a detonator gem and a gravityFieldNode to add to the scene and simulates the gem exploding in the scene
        if detonatorGem.parent != nil { // Don't simulate explosion if gem has been removed
            let gemPosition = detonatorGem.position
            detonatorGem.removeFromParent()
            
            let gemExplosion = SKEmitterNode(fileNamed: "gemExplosion")!
            gemExplosion.position = gemPosition
            addChild(gemExplosion)
            
            run(gemExplosionSound)
            
            gravityFieldNode.name = "gravityFieldNode"
            gravityFieldNode.strength = -30
            gravityFieldNode.position = gemPosition
            addChild(gravityFieldNode)
        }
    }
    
    private func detonationCleanup(gravityFieldNode: SKFieldNode) {
        // Takes a gravityFieldNode and removes it from the scene to end the gem explosion simulation.
        if gravityFieldNode.parent != nil {
            gravityFieldNode.removeFromParent()
        }
    }
    
    private func detonateGemSequence(timeToExplosion: Double) {
        // Adds a detonating gem to the scene and makes it explode in timeToExplosion seconds.
        let detonatorGem = Gem(imageNamed: "rottenGem")
        let gravityFieldNode = SKFieldNode.radialGravityField()
        
        run(SKAction.sequence([
            SKAction.run({self.addDetonatorGem(detonatorGem: detonatorGem)}),
            SKAction.run({self.animateDetonatorGem(detonatorGem: detonatorGem)}),
            SKAction.wait(forDuration: timeToExplosion),
            SKAction.run({self.detonateGem(detonatorGem: detonatorGem, gravityFieldNode: gravityFieldNode)}),
            SKAction.wait(forDuration: 0.25),
            SKAction.run({self.detonationCleanup(gravityFieldNode: gravityFieldNode)})
            ]))
    }
    

    private func minusAlert(text: String) {
        let minus = SKLabelNode(fontNamed: "Menlo-Bold")
        minus.text = text
        minus.fontColor = SKColor.red
        minus.fontSize = 30
        minus.position = CGPoint(x: size.width * 0.8, y: size.height * 0.9)
        addChild(minus)
        
        let moveDown = SKAction.moveTo(y: size.height * 0.7, duration: 0.6)
        minus.run(moveDown)
        minus.run(SKAction.fadeOut(withDuration: 1.0))
        
        if text == "-5" {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    private func animateLeftHammer() { // Need a function without arguments to be called in the SKAction
        leftGemSource.run(SKAction.animate(with: hammerFrames, timePerFrame: 0.35)) // Animation consists of 2 frames.
    }
    
    private func animateRightHammer() { // Need a function without arguments to be called in the SKAction
        rightGemSource.run(SKAction.animate(with: hammerFrames, timePerFrame: 0.35)) // Animation consists of 2 frames.
    }
    
    private func shakeAction(positionX : CGFloat) -> SKAction {
        //returns a shaking animation
        
        //defining a shake sequence
        var sequence = [SKAction]()
        
        //Filling the sequence
        for i in (1...4).reversed() {
            let moveRight = SKAction.moveBy(x: CGFloat(i*2), y: 0, duration: TimeInterval(0.05))
            sequence.append(moveRight)
            let moveLeft = SKAction.moveBy(x: CGFloat(-4*i), y: 0, duration: TimeInterval(0.1))
            sequence.append(moveLeft)
            let moveOriginal = SKAction.moveBy(x: CGFloat(i*2), y: 0, duration: (TimeInterval(0.05)))
            sequence.append(moveOriginal)
        }
        sequence.append(SKAction.moveTo(x: positionX, duration: 0.05)) //Return to original x position
        let shake = SKAction.sequence(sequence)
        return shake
    }
    
    // Helper methods to generate random numbers.
    private func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    private func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}