//
//  SettingsScene.swift
//  Ceres
//
//  Created by Sean Cheng on 4/25/17.
//  Copyright © 2017 Stellanova. All rights reserved.
//

import Foundation
import SpriteKit

class SettingsScene: SKScene {
    
    let title = "Settings"
    let titleNode = SKLabelNode(fontNamed: "Optima-Bold")
    
    var backButton = SKSpriteNode()
    let backButtonTex = SKTexture(imageNamed: "back")
    
    let musicLabel = SKLabelNode(fontNamed: "Optima-Bold")
    var musicSwitch = UISwitch()
    
    let soundLabel = SKLabelNode(fontNamed: "Optima-Bold")
    var soundSwitch = UISwitch()
    
    let defaults:UserDefaults = UserDefaults.standard
    
    var starfield:SKEmitterNode!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        createMusicSwitch()
        showMusicSwitchLabel()

        createSoundSwitch()
        showSoundSwitchLabel()
        
        titleNode.text = title
        titleNode.fontSize = 32
        titleNode.fontColor = SKColor.white
        titleNode.position = CGPoint(x: size.width/2, y: size.height - size.height/6)
        addChild(titleNode)
        
        backButton = SKSpriteNode(texture: backButtonTex)
        backButton.setScale(0.175)
        backButton.position = CGPoint(x: size.width/12, y: size.height - size.height/24)
        addChild(backButton)
        
        starfield = SKEmitterNode(fileNamed: "starShower")
        starfield.position = CGPoint(x: 0, y: size.height)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = -1
        
        defaults.set(findDefaultValue(key: "MusicOnOff"), forKey: "MusicOnOff")
        defaults.set(findDefaultValue(key: "SoundOnOff"), forKey: "SoundOnOff")
    }
    
    private func findDefaultValue(key: String) -> Bool {
        if !defaults.bool(forKey: key) {
            return false
        } else { return true }
    }
    
    public func createMusicSwitch() {
        musicSwitch = UISwitch(frame: CGRect(x: frame.midX + size.width/10, y: size.height/4, width: 2, height: 2))
        musicSwitch.setOn(defaults.bool(forKey: "MusicOnOff"), animated: false)
        musicSwitch.addTarget(self, action: #selector(musicSwitchOnOff(sender:)), for: .valueChanged)
        self.view!.addSubview(musicSwitch)
    }
    
    func musicSwitchOnOff(sender:UISwitch!) {
        if sender.isOn == false {
            defaults.set(false, forKey: "MusicOnOff")
        }
        else {
            defaults.set(true, forKey: "MusicOnOff")
        }
    }
    
    private func showMusicSwitchLabel() {
        musicLabel.text = "Music"
        musicLabel.fontSize = 25
        musicLabel.fontColor = SKColor.white
        musicLabel.position = CGPoint(x: size.width/2 - size.width/12, y: size.height * 3/4 - size.height/22)
        addChild(musicLabel)
    }
    
    public func createSoundSwitch() {
        soundSwitch = UISwitch(frame: CGRect(x: frame.midX + size.width/10, y: size.height * 3/8, width: 2, height: 2))
        soundSwitch.setOn(defaults.bool(forKey:"SoundOnOff"), animated: false)
        soundSwitch.addTarget(self, action: #selector(soundSwitchOnOff(sender:)), for: .valueChanged)
        self.view!.addSubview(soundSwitch)
    }
    
    func soundSwitchOnOff(sender:UISwitch!) {
        if sender.isOn == false {
            defaults.set(false, forKey: "SoundOnOff")
        }
        else {
            defaults.set(true, forKey: "SoundOnOff")
        }
    }
    
    private func showSoundSwitchLabel() {
        soundLabel.text = "Sound Effects"
        soundLabel.fontSize = 25
        soundLabel.fontColor = SKColor.white
        soundLabel.position = CGPoint(x: size.width/2 - size.width/5, y: size.height * 5/8 - size.height/22)
        addChild(soundLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //looks for a touch
        if let touch = touches.first{
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            //transitions back to menu screen if back button is touched
            if node == backButton {
                if view != nil {
                    musicSwitch.removeFromSuperview()
                    soundSwitch.removeFromSuperview()
                    let transition:SKTransition = SKTransition.crossFade(withDuration: 1)
                    let scene:SKScene = MenuScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
    
}
