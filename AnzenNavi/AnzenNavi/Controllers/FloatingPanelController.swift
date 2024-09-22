//
//  FloatingPanelController.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import UIKit
import FloatingPanel

class FloatingPanelController: UIViewController, FloatingPanelControllerDelegate {
    var fpc: FloatingPanel.FloatingPanelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // FloatingPanelの初期化
        fpc = FloatingPanel.FloatingPanelController()
        fpc.delegate = self

        // コンテンツビューコントローラの設定
        let contentVC = FloatingPanelContentViewController()
        fpc.set(contentViewController: contentVC)

        // パネルを画面に追加
        fpc.addPanel(toParent: self)
    }
}

// FloatingPanelに表示するコンテンツ
class FloatingPanelContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // パネル内のコンテンツを作成
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "避難所情報"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        // レイアウト設定
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

