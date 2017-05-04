//
//  GameScene.swift
//  Ceres
//
//  Created by Steven Roach on 2/15/17.
//  Copyright © 2017 Stellanova. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate, Alerts {
    
    var tutorialMode = false // Boolean to store whether game is in tutorialMode
    
    // Global nodes
    let pauseButton = SKSpriteNode(imageNamed: "pause")
    let gemCollector = GemCollector(imageNamed: "collectorActive")
    let stagePlanet = StagePlanet(imageNamed: "planet")
    let leftGemSource  = GemSource(imageNamed: "hammerInactive")
    let rightGemSource = GemSource(imageNamed: "hammerInactive")
    let redAstronaut = SKSpriteNode(imageNamed: "redAstronaut")
    let blueAstronaut = SKSpriteNode(imageNamed: "blueAstronaut")
    var starfield:SKEmitterNode!
    
    // Tutorial assets
    let flickHand = SKSpriteNode(imageNamed: "touch")
    let collectorGlow = SKEmitterNode(fileNamed: "collectorGlow")!
    
    
    var losingGemPlusMinus = -1 // Make this lower during testing. This should be a constant but isn't because we change it to avoid the gameOver transition happening multiple times. TOOD: Change is back to a constant when a better solution for the gameOver is found.
    
    var gemsLabel: SKLabelNode!
    var gemsPlusMinus = 0 {
        didSet {
            gemsLabel.text = "Gems: \(gemsPlusMinus)"
        }
    }
    
    var scoreLabel: SKLabelNode!
    var timerSeconds = 0 {
        didSet {
            scoreLabel.text = "Score: \(timerSeconds)"
        }
    }
    var timeToBeginNextSequence:Double = 0.0 // Initialize to 0.0 so sequence will start when gameplay begins
    
    
    var spawnSequenceManager: SpawnSequenceManager = SpawnSequenceManager()
    var audioManager: AudioManager = AudioManager()
    
    
    let pauseTexture = SKTexture(imageNamed: "pause")
    let playTexture = SKTexture(imageNamed: "play")
    
    
    // This is the single source of truth for if the game is paused. Changes this variable pauses game elements and brings up pause layer or vice versa.
    var gamePaused = false {
        didSet {
            pauseLayer.isHidden = !gamePaused
            isPaused = gamePaused
            gamePaused == true ? (physicsWorld.speed = 0) : (physicsWorld.speed = 1.0)
            gamePaused == true ? (audioManager.pauseBackgroundMusic()) : (audioManager.resumeBackgroundMusic())
            gamePaused == true ? (pauseButton.isHidden = true) : (pauseButton.isHidden = false)
        }
    }
    
    // This variable is automatically set to false when the scene is loaded which is not desired. We override it so that it always has the same value as gamePaused.
    override var isPaused: Bool {
        didSet {
            if isPaused != gamePaused {
                isPaused = gamePaused
            }
        }
    }
    
    // TODO: Refactor into Animation manager class
    var collectorAtlas = SKTextureAtlas()
    var collectorFrames = [SKTexture]()
    var hammerAtlas = SKTextureAtlas()
    var hammerFrames = [SKTexture]()
    
    
    // Data structures to deal with user touches
    var touchesToGems:[UITouch: SKSpriteNode] = [:] // Dictionary to map currently selected user touches to the gems they are dragging
    var selectedGems: Set<SKSpriteNode> = Set()
    var nodeDisplacements:[SKSpriteNode: CGVector] = [:] // Dictionary to map currently selected nodes to their displacements from the user's finger
    
    let gameLayer = SKNode()
    let pauseLayer = SKNode()
    
    
    
    
    override func didMove(to view: SKView) {
        // Called immediately after scene is presented.
        
        self.name = "game" // Identify scene as game so that GameViewController knows when the viewed scene is the GameScene

        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.black
        starfield = SKEmitterNode(fileNamed: "starShower")
        starfield.position = RelativePositions.Starfield.getAbsolutePosition(size: size)
        starfield.zPosition = -10
        starfield.advanceSimulationTime(1)
        gameLayer.addChild(starfield)
        
        pauseButton.setScale(0.175)
        pauseButton.name = "pauseButton"
        pauseButton.position = RelativePositions.PauseButton.getAbsolutePosition(size: size)
        gameLayer.addChild(pauseButton)
        
        setScoreLabel()
        
        addStagePlanet()
        addGemCollector()
        addGemSources()
        addAstronauts()
        
        makeWall(location: CGPoint(x: size.width/2, y: size.height + PositionConstants.wallOffScreenDistance), size: CGSize(width: size.width*1.5, height: 1))
        makeWall(location: CGPoint(x: -PositionConstants.wallOffScreenDistance, y: size.height/2), size: CGSize(width: 1, height: size.height+100))
        makeWall(location: CGPoint(x: size.width + PositionConstants.wallOffScreenDistance, y: size.height/2), size: CGSize(width: 1, height: size.height+100))
        
        collectorAtlas = SKTextureAtlas(named: "collectorImages")
        collectorFrames.append(SKTexture(imageNamed: "collectorActive.png"))
        collectorFrames.append(SKTexture(imageNamed: "collectorInactive.png"))
        hammerAtlas = SKTextureAtlas(named: "hammerImages")
        hammerFrames.append(SKTexture(imageNamed: "hammerActive.png"))
        hammerFrames.append(SKTexture(imageNamed: "hammerInactive.png"))
        
        gameLayer.addChild(audioManager) // Pausing audio manager doesn't pause audio so this doesn't have to be a child of gameLayer
        audioManager.playBackgroundMusic()
    
        startTutorialMode()
        
        addPauseLayer()
        addChild(gameLayer)
    }
    
    
    // Functions that add nodes to scene
    private func makeWall(location: CGPoint, size: CGSize) {
        // Creates boundaries in the game that deletes gems when they come into contact
        
        let shape = SKShapeNode(rectOf: size)
        shape.position = location
        shape.physicsBody = SKPhysicsBody(rectangleOf: size)
        shape.physicsBody?.isDynamic = false
        shape.physicsBody?.usesPreciseCollisionDetection = true
        shape.physicsBody?.categoryBitMask = PhysicsCategories.Wall;
        shape.physicsBody?.contactTestBitMask = PhysicsCategories.Gem;
        shape.physicsBody?.collisionBitMask = PhysicsCategories.None;
        gameLayer.addChild(shape)
    }
    
    private func setScoreLabel() {
        // Tracks current game time
        
        scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        scoreLabel.text = "Score: \(timerSeconds)"
        scoreLabel.fontSize = 20
        //scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = RelativePositions.ScoreLabel.getAbsolutePosition(size: size)
        gameLayer.addChild(scoreLabel)
    }

    private func addStagePlanet() {
        stagePlanet.setStagePlanetProperties()  // Calls stage properties from StagePlanet class
        stagePlanet.position = RelativePositions.StagePlanet.getAbsolutePosition(size: size)
        gameLayer.addChild(stagePlanet)
    }
    
    private func addGemCollector() {
        gemCollector.setGemCollectorProperties()  // Calls gem collector properties from GemCollector class
        gemCollector.position = RelativePositions.Collector.getAbsolutePosition(size: size)
        gameLayer.addChild(gemCollector)
    }
    
    private func addGemSources() {
        // Adds 2 gem sources, one for each astronaut
        
        leftGemSource.setGemSourceProperties()  // Calls gem source properties from GemSource class
        leftGemSource.position = RelativePositions.LeftGemSource.getAbsolutePosition(size: size, constantY: -PositionConstants.gemSourceDistBelowAstronaut)
        leftGemSource.name = "leftGemSource"
        gameLayer.addChild(leftGemSource)
        
        rightGemSource.setGemSourceProperties()  // Calls gem source properties from GemSource class
        rightGemSource.position = RelativePositions.RightGemSource.getAbsolutePosition(size: size, constantY: -PositionConstants.gemSourceDistBelowAstronaut)
        rightGemSource.name = "rightGemSource"
        gameLayer.addChild(rightGemSource)
    }
    
    private func addAstronauts() {
        // Creates 2 astronauts on either side of the planet
        
        redAstronaut.position = RelativePositions.LeftAstronaut.getAbsolutePosition(size: size)
        redAstronaut.setScale(0.175)
        redAstronaut.name = "redAstronaut"
        redAstronaut.zPosition = 2
        redAstronaut.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0.1*(size.width), height: 0.13*(size.height)))
        redAstronaut.physicsBody?.usesPreciseCollisionDetection = true
        redAstronaut.physicsBody?.isDynamic = false
        redAstronaut.isUserInteractionEnabled = false // Must be set to false in order to register touch events.
        
        blueAstronaut.position = RelativePositions.RightAstronaut.getAbsolutePosition(size: size)
        blueAstronaut.setScale(0.175)
        blueAstronaut.name = "blueAstronaut"
        blueAstronaut.zPosition = 2
        blueAstronaut.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0.1*(size.width), height: 0.13*(size.height)))
        blueAstronaut.physicsBody?.usesPreciseCollisionDetection = true
        blueAstronaut.physicsBody?.isDynamic = false // Change this to true to be amused
        blueAstronaut.isUserInteractionEnabled = false // Must be set to false in order to register touch events.
        
        gameLayer.addChild(redAstronaut)
        gameLayer.addChild(blueAstronaut)
    }
    
    
    private func addPauseLayer() {
        
        let pauseMenu = SKSpriteNode(imageNamed: "pauseMenu")
        let pauseMenuSize = RelativeScales.PauseMenu.getAbsoluteSize(screenSize: size, nodeSize: pauseMenu.size)
        pauseMenu.xScale = pauseMenuSize.width
        pauseMenu.xScale = pauseMenuSize.height
        pauseMenu.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        pauseMenu.zPosition = 8
        pauseLayer.addChild(pauseMenu)
        
        let resume = SKSpriteNode(imageNamed: "play")
        resume.name = "resume"
        resume.setScale(0.3 * (size.width / resume.size.width))
        resume.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        resume.zPosition = 9
        pauseLayer.addChild(resume)
        
        let back = SKSpriteNode(imageNamed: "back")
        back.name = "back"
        back.setScale(0.2 * (size.width / back.size.width))
        back.position = CGPoint(x: size.width * 0.2, y: size.height * 0.5)
        back.zPosition = 9
        pauseLayer.addChild(back)
        
        let restart = SKSpriteNode(imageNamed: "replay")
        restart.name = "restart"
        restart.setScale(0.2 * (size.width / restart.size.width))
        restart.zPosition = 9
        restart.position = CGPoint(x: size.width * 0.8, y: size.height * 0.5)
        pauseLayer.addChild(restart)
        
        pauseLayer.zPosition = 100
        pauseLayer.isHidden = true
        addChild(pauseLayer)
    }
    
    func onPauseButtonTouch() {
        gamePaused = true
    }
    
    public func collectGemAnimation(collector: SKSpriteNode, implosion: Bool) {
        collector.run(SKAction.repeat(SKAction.animate(with: collectorFrames, timePerFrame: 0.25), count: 1))
        
        let tempCollectorGlow = SKEmitterNode(fileNamed: "collectorGlow")!
        tempCollectorGlow.position = RelativePositions.CollectorGlow.getAbsolutePosition(size: size)
        tempCollectorGlow.numParticlesToEmit = 8
        if implosion {
            tempCollectorGlow.particleColorSequence = nil;
            tempCollectorGlow.particleColorBlendFactor = 0.8
            tempCollectorGlow.particleColor = UIColor.red
            tempCollectorGlow.numParticlesToEmit = tempCollectorGlow.numParticlesToEmit * 2
        }
        gameLayer.addChild(tempCollectorGlow)
        // Remove collector glow node after 3 seconds
        run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run({tempCollectorGlow.removeFromParent()})]))
    }
    
    public func flashGemsLabelAnimation(color: SKColor, percentGrowth: Double = 1.075) {
        
        let colorScore = SKAction.run({self.gemsLabel.fontColor = color})
        let expand = SKAction.scale(by: CGFloat(percentGrowth), duration: 0.25)
        let shrink = SKAction.scale(by: CGFloat(1 / percentGrowth), duration: 0.25)
        let recolorWhite = SKAction.run({self.gemsLabel.fontColor = SKColor.white})
        let flashAnimation = SKAction.sequence([colorScore, expand, shrink, recolorWhite])
        
        gemsLabel.run(flashAnimation)
    }
    
}
