//
//  Positions.swift
//  Ceres
//
//  Created by Steven Roach on 5/1/17.
//  Copyright © 2017 Stellanova. All rights reserved.
//

import Foundation
import SpriteKit


// This file defines structures used for positioning.


public struct RelativePositions {
    // Holds relative coordinates to be used for positioning
    
    static let Collector = RelativeCoordinate.init(x: 0.5, y: 0.085)
    static let GemsLabel = RelativeCoordinate.init(x: 0.8, y: 0.95)
    static let InitialGemsLabel = RelativeCoordinate.init(x: 0.5, y: 0.7)
    static let PauseButton = RelativeCoordinate.init(x: 1/12, y: 23/24)
    static let ScoreLabel = RelativeCoordinate.init(x: 0.4, y: 19/20)
    static let StagePlanet = RelativeCoordinate.init(x: 0.5, y: 0.075)
    static let LeftGemSource = RelativeCoordinate.init(x: 0.15, y: 0.1)
    static let RightGemSource = RelativeCoordinate.init(x: 0.85, y: 0.1)
    static let GemSpawnLeft = RelativeCoordinate.init(x: 0.15, y: 0.15)
    static let GemSpawnRight = RelativeCoordinate.init(x: 0.85, y: 0.15)
    static let LeftAstronaut = RelativeCoordinate.init(x: 0.15, y: 0.1)
    static let RightAstronaut = RelativeCoordinate.init(x: 0.85, y: 0.1)
    static let CollectorGlow = RelativeCoordinate.init(x: 0.525, y: 0.125)
    static let Starfield = RelativeCoordinate.init(x: 0, y: 1)
    static let TutorialGem = RelativeCoordinate.init(x: 0.5, y: 0.5)
    static let FlickHand = RelativeCoordinate.init(x: 0.65, y: 0.45)
    static let FlickHandTouch = RelativeCoordinate.init(x: 0.55, y: 0.45)
    static let FlickHandDownSlow = RelativeCoordinate.init(x: 0.55, y: 0.4)
    static let FlickHandDownFast = RelativeCoordinate.init(x: 0.55, y: 0.225)
    static let FlickHandRelease = RelativeCoordinate.init(x: 0.575, y: 0.25)
    static let FlickHandReset = RelativeCoordinate.init(x: 0.675, y: 0.45)
    static let MinusAlert = RelativeCoordinate.init(x: 0.8, y: 0.9)
}


public struct PositionConstants {
    // Holds constants used for positioning
    static let wallOffScreenDistance: CGFloat = 50
    static let gemSourceDistBelowAstronaut: CGFloat = 20
}


public struct RelativeCoordinate {
    // Data structure to define relative positions
    
    let x: CGFloat
    let y: CGFloat
    
    public func getAbsolutePosition(size: CGSize, constantX: CGFloat = 0, constantY: CGFloat = 0) -> CGPoint {
        // Takes a size and constants to shift the position by and returns the absolute position of the coordinate.
        return CGPoint(x: (size.width * self.x) + constantX, y: (size.height * self.y) + constantY)
    }
}



