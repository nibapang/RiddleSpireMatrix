//
//  DotGameVC.swift
//  RiddleSpireMatrix
//
//  Created by RiddleSpireMatrix on 03/02/25.
//

import Foundation
import UIKit

class MatrixDotGameViewController: UIViewController {
    
    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel! // New lives system
    @IBOutlet weak var segmentControl: UISegmentedControl!

    private var dots: [UIView] = []
    private var blankDotIndex: Int = 0
    private var selectedSegmentIndex: Int = 0
    private var score = 0
    private var timer: Timer?
    private var timeRemaining = 60
    private var lives = 3 // New lives counter
    private var consecutiveCorrectTaps = 0

    private let segments = ["Easy", "Medium", "Hard", "Expert"]
    private var totalDots: Int {
        switch selectedSegmentIndex {
        case 0: return 4 // Easy
        case 1: return 6 // Medium
        case 2: return 8 // Hard
        case 3: return 10 // Expert
        default: return 4
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Blink Dot Challenge"
        setupSegmentControl()
        resetGame()
    }

    private func setupSegmentControl() {
        segmentControl.removeAllSegments()
        for (index, title) in segments.enumerated() {
            segmentControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    @objc private func segmentChanged() {
        selectedSegmentIndex = segmentControl.selectedSegmentIndex
        resetGame()
    }

    private func resetGame() {
        score = 0
        lives = 3 // Reset lives
        timeRemaining = 60
        consecutiveCorrectTaps = 0
        updateScoreLabel()
        updateTimerLabel()
        updateLivesLabel()
        generateDots()
        startTimer()
    }

    private func generateDots() {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        let radius = gameBoardView.bounds.width / 2 - 20
        let center = CGPoint(x: gameBoardView.bounds.midX, y: gameBoardView.bounds.midY)
        let angleIncrement = 2 * CGFloat.pi / CGFloat(totalDots)

        blankDotIndex = Int.random(in: 0..<totalDots)

        for i in 0..<totalDots {
            let angle = angleIncrement * CGFloat(i)
            let dotCenter = CGPoint(x: center.x + radius * cos(angle),
                                     y: center.y + radius * sin(angle))
            
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            dot.center = dotCenter
            dot.layer.cornerRadius = 20
            dot.backgroundColor = (i == blankDotIndex) ? .clear : .systemBlue
            dot.layer.borderWidth = (i == blankDotIndex) ? 2 : 0
            dot.layer.borderColor = UIColor.systemGray.cgColor
            dot.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dotTapped(_:)))
            dot.addGestureRecognizer(tapGesture)

            gameBoardView.addSubview(dot)
            dots.append(dot)
        }
    }

    @objc private func dotTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedDot = sender.view, let index = dots.firstIndex(of: tappedDot) else { return }

        if index == blankDotIndex {
            // Correct Selection
            tappedDot.backgroundColor = .systemGreen
            consecutiveCorrectTaps += 1
            score += 1 + consecutiveCorrectTaps // Bonus for consecutive correct taps
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.generateDots()
                self.updateScoreLabel()
            }
        } else {
            // Incorrect Selection
            tappedDot.backgroundColor = .systemRed
            consecutiveCorrectTaps = 0
            lives -= 1 // Lose a life instead of losing points
            updateLivesLabel()
            
            if lives == 0 {
                endGame(reason: "You lost all lives!")
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            self.updateTimerLabel()

            if self.timeRemaining <= 0 {
                self.endGame(reason: "Time’s up!")
            }
        }
    }

    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    private func updateTimerLabel() {
        timerLabel.text = "Time: \(timeRemaining)s"
    }
    
    private func updateLivesLabel() {
        livesLabel.text = "Lives: \(lives)"
    }

    private func endGame(reason: String) {
        timer?.invalidate()
        
        let alert = UIAlertController(title: "Game Over", message: "\(reason)\nYour final score: \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { [weak self] _ in
            self?.resetGame()
        }))
        alert.addAction(UIAlertAction(title: "Quit", style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}
