//
//  SpawnSequenceManager.swift
//  Ceres
//
//  Created by Steven Roach on 4/22/17.
//  Copyright © 2017 Stellanova. All rights reserved.
//

import Foundation
import SpriteKit


class SpawnSequenceManager { 
    
    private let spawnSequence1: GameScene.SpawnAction =
        .repeated(times: 5,
                  action: .sequence(actions: [.wait(time: 1), .spawnGemLeft, .wait(time: 1), .spawnGemRight]))
    
    private let spawnSequence2: GameScene.SpawnAction =
        .repeated(times: 8,
                  action: .sequence(actions: [.wait(time: 1), .spawnGemLeft, .wait(time: 0.25), .spawnGemRight]))
    
    private let spawnSequence3: GameScene.SpawnAction =
        .repeated(times: 7, action:
            .sequence(actions: [.wait(time: 1),
                                .spawnGemLeft,
                                .wait(time: 0.25),
                                .spawnGemLeft, .spawnDetonatorLeft,
                                .wait(time: 0.25),
                                .spawnGemLeft, .spawnGemRight]))
    
    private let spawnSequence4: GameScene.SpawnAction =
        .repeated(times: 2, action:
            .sequence(actions: [.wait(time: 2.47),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnDetonatorLeft,
                                .wait(time: 0.01),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnDetonatorLeft,
                                
                                .wait(time: 2.47),
                                .spawnGemLeft,
                                .wait(time: 0.01),
                                .spawnGemLeft,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnDetonatorLeft,
                                .wait(time: 0.01),
                                .spawnGemLeft,
                                ]))
    
    private let spawnSequenceBasicDetonators: GameScene.SpawnAction =
        .repeated(times: 2, action:
            .sequence(actions: [.wait(time: 2.47),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnDetonatorLeft,
                                
                                .wait(time: 2.47),
                                .spawnGemLeft,
                                .wait(time: 0.01),
                                .spawnGemLeft,
                                .wait(time: 0.01),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnDetonatorRight
                ]))
    
    private let spawnSequenceHard: GameScene.SpawnAction =
        .repeated(times: 10, action:
            .sequence(actions: [.wait(time: 0.75),
                                .spawnGemRight,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnGemLeft,
                                .wait(time: 0.01),
                                .spawnGemRight, .spawnDetonatorLeft,
                                
                                .wait(time: 0.21),
                                .spawnGemLeft,
                                .wait(time: 0.01),
                                .spawnGemLeft, .spawnGemRight, .spawnDetonatorLeft,
                                .wait(time: 0.01),
                                .spawnGemLeft,
                                ]))
    
    
    
    
    // Start making sequences after this line
    
    let basicSequences:[GameScene.SpawnAction]
    let easySequences:[GameScene.SpawnAction]
//    let mediumSequences:[GameScene.SpawnAction]
//    let hardSequences:[GameScene.SpawnAction]
//    let veryHardSequences:[GameScene.SpawnAction]
//    let impossibleSequences:[GameScene.SpawnAction]
    
    private let basicSequence0: GameScene.SpawnAction =
        .repeated(times: 4,
                  action: .sequence(actions: [.wait(time: 0.9), .spawnGemLeft, .wait(time: 0.9), .spawnGemRight]))
    
    private let basicSequence1: GameScene.SpawnAction =
        .repeated(times: 4,
                  action: .sequence(actions: [.wait(time: 0.9), .spawnGemRight, .wait(time: 0.9), .spawnGemLeft]))

    
    private let easySequence0: GameScene.SpawnAction =
        .repeated(times: 6,
                  action: .sequence(actions: [.wait(time: 1.1), .spawnGemLeft, .wait(time: 0.25), .spawnGemRight]))
    
    private let easySequence1: GameScene.SpawnAction =
        .repeated(times: 2,
                  action: .sequence(actions: [.wait(time: 1.2), .spawnGemRight,
                                             .wait(time: 0.5), .spawnGemLeft,
                                             .wait(time: 0.5), .spawnGemRight,
                                             .wait(time: 1.2), .spawnGemLeft,
                                             .wait(time: 0.5), .spawnGemRight,
                                             .wait(time: 0.5), .spawnGemLeft]))
    
    private let easySequence2: GameScene.SpawnAction =
        .repeated(times: 6,
                  action: .sequence(actions: [.wait(time: 1.2), .spawnGemRight, .spawnGemLeft]))
    
    private let easySequence3: GameScene.SpawnAction =
        .repeated(times: 2,
                  action: .sequence(actions: [.repeated(times: 3, action: .sequence(actions: [.wait(time: 0.7), .spawnGemRight])),
                                             .repeated(times: 3, action: .sequence(actions: [.wait(time: 0.7), .spawnGemLeft]))]))
    
    var index = 0
    
    public init() {
        
        basicSequences = [basicSequence0, basicSequence1]
        easySequences = [easySequence0, easySequence1, easySequence2, easySequence3]
//        mediumSequences = []
//        hardSequences = []
//        veryHardSequences = []
//        impossibleSequences = []
        
    }
    
    public func getSpawnSequence(time: Int) -> GameScene.SpawnAction {
        // Gem spawning routine
        
        if index < easySequences.count {
            let sequence = easySequences[index]
            index += 1
            return sequence
        } else {
            return spawnSequenceHard
        }
    }
        
}


