//
//  DragVC.swift
//  RiddleSpireMatrix
//
//  Created by jin fu on 03/02/25.
//

import UIKit
import SpriteKit

class MatrixDragViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        let scene = MatrixAlphabetGameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
}
