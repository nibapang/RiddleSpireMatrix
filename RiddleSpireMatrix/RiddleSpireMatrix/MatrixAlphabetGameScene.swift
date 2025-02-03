//
//  AlphabetGameScene.swift
//  RiddleSpireMatrix
//
//  Created by RiddleSpireMatrix on 03/02/25.
//

import SpriteKit

class MatrixAlphabetGameScene: SKScene {
    var alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    var missingIndexes: [Int] = []
    var filledLetters: [Character?] = []
    var missingLetters: [Character] = []
    var letterNodes: [SKShapeNode] = []
    var draggableNodes: [SKShapeNode] = []
    var selectedLetter: Character?
    var draggedNode: SKShapeNode?
    var originalPosition: CGPoint?
    
    var timerLabel: SKLabelNode!
    var timer: Timer?
    var timeLeft = 60
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupData()
        setupGrid()
        setupDraggableLetters()
        setupTimer()
    }

    func setupBackground() {
        let bg = SKSpriteNode(imageNamed: "bg") // Replace with your image name
        bg.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        bg.size = self.size // Ensure it covers the full screen
        bg.zPosition = -1   // Send it to the back layer
        bg.alpha = 0.4
        addChild(bg)
    }

    func setupData() {
        missingIndexes = Array(0..<alphabet.count).shuffled().prefix(20).sorted()
        filledLetters = alphabet.map { missingIndexes.contains(alphabet.firstIndex(of: $0)!) ? nil : $0 }
        missingLetters = missingIndexes.map { alphabet[$0] }.shuffled()
    }
    
    func setupGrid() {
        let cols = 5
        let cellSize: CGFloat = 50
        let totalRows = (alphabet.count + cols - 1) / cols
        
        let screenCenterX = self.size.width / 2
        let screenCenterY = self.size.height / 2
        
        let gridWidth = CGFloat(cols) * cellSize
        let gridHeight = CGFloat(totalRows) * cellSize
        
        let startX = screenCenterX - (gridWidth / 2) + (cellSize / 2)
        let startY = screenCenterY + (gridHeight / 2) - (cellSize / 2) + 100
        
        for (index, letter) in filledLetters.enumerated() {
            let row = index / cols
            let col = index % cols
            let node = SKShapeNode(circleOfRadius: cellSize / 2)
            node.position = CGPoint(x: startX + CGFloat(col) * cellSize,
                                    y: startY - CGFloat(row) * cellSize)
            node.fillColor = letter != nil ? .white : .orange
            node.name = letter == nil ? "empty" : "filled"
            
            let label = SKLabelNode(text: letter != nil ? String(letter!) : "?")
            label.fontSize = 24
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            node.addChild(label)
            
            addChild(node)
            letterNodes.append(node)
        }
    }
    
    func setupDraggableLetters() {
        let cols = 5
        let spacing: CGFloat = 40
        let totalRows = (missingLetters.count + cols - 1) / cols
        
        let startX = self.size.width / 2 - (CGFloat(cols) * spacing / 2) + (spacing / 2)
        let startY = self.size.height * 0.2 + 100
        
        for (index, letter) in missingLetters.enumerated() {
            let row = index / cols
            let col = index % cols
            let node = SKShapeNode(circleOfRadius: spacing / 2)
            node.position = CGPoint(x: startX + CGFloat(col) * spacing,
                                    y: startY - CGFloat(row) * spacing)
            node.fillColor = .cyan
            node.name = "draggable"
            
            let label = SKLabelNode(text: String(letter))
            label.fontSize = 24
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            node.addChild(label)
            
            addChild(node)
            draggableNodes.append(node)
        }
    }
    
    func setupTimer() {
        timerLabel = SKLabelNode(text: "Time: \(timeLeft)")
        timerLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 80)
        timerLabel.fontSize = 28
        timerLabel.fontColor = .white
        addChild(timerLabel)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    func updateTimer() {
        timeLeft -= 1
        timerLabel.text = "Time: \(timeLeft)"
        
        if timeLeft <= 0 {
            timer?.invalidate()
            showGameOver()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        
        // Check if the user tapped on the restart label
        if node.name == "restart" {
            restartGame()
            return
        }
        
        // Detect draggable letter selection
        if let label = node as? SKLabelNode, let parent = label.parent as? SKShapeNode {
            if parent.name == "draggable" {
                draggedNode = parent
                originalPosition = parent.position
                parent.zPosition = 100
                selectedLetter = label.text?.first
            }
        }
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedNode = draggedNode else { return }
        let location = touch.location(in: self)
        draggedNode.position = location

        for node in letterNodes {
            if node.name == "empty" && node.frame.contains(location) {
                node.fillColor = .yellow
            } else if node.name == "empty" {
                node.fillColor = .orange
            }
        }
    }
    func restartGame() {
        // Reset screen flip before transitioning
        self.run(SKAction.scaleX(to: 1.0, duration: 0.5)) {
            let newScene = MatrixAlphabetGameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            self.view?.presentScene(newScene, transition: .crossFade(withDuration: 0.5))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let node = draggedNode, let selected = selectedLetter {
            var letterPlaced = false
            
            for targetNode in letterNodes {
                if targetNode.name == "empty" && targetNode.frame.contains(location) {
                    if let index = letterNodes.firstIndex(of: targetNode) {
                        let correctLetter = alphabet[index]
                        if let label = targetNode.children.first as? SKLabelNode {
                            if selected == correctLetter {
                                label.text = String(selected)
                                targetNode.fillColor = .green
                                targetNode.name = "filled"
                                node.removeFromParent()
                                letterPlaced = true
                            } else {
                                targetNode.fillColor = .red
                            }
                        }
                    }
                }
            }
            
            if !letterPlaced, let originalPos = originalPosition {
                let moveBack = SKAction.move(to: originalPos, duration: 0.2)
                node.run(moveBack)
            }
            
            node.zPosition = 0
        }
        
        draggedNode = nil
        originalPosition = nil
        selectedLetter = nil
        checkGameCompletion()
    }

    func checkGameCompletion() {
        if letterNodes.allSatisfy({ $0.name == "filled" }) {
            timer?.invalidate()
            showWinMessage()
        }
    }

    func showWinMessage() {
        let label = SKLabelNode(text: "Congratulations! Tap to Restart")
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 100)
        label.fontSize = 20
        label.fontName = "Avenir-Heavy" // Use a bold system font
        label.fontColor = .white
        label.name = "restart"
        addChild(label)
    }

    func showGameOver() {
        let label = SKLabelNode(text: "Game Over! Tap to Restart")
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 100)
        label.fontSize = 20
        label.fontColor = .red
        label.fontName = "Avenir-Heavy" // Use a bold system font
        label.name = "restart"
        addChild(label)
        
        // Flip the screen horizontally
        let flipAction = SKAction.scaleX(to: -1.0, duration: 0.5)
        self.run(flipAction)
    }


}
