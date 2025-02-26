//
//  FloatingPannel.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/09.
//

import SwiftUI
import UIKit
import FloatingPanel

extension View {
    func floatingPanel(selectedTab: Binding<Int>, selectedShelter: Binding<Shelter?>) -> some View {
        FloatingPanelView(parent: { self }, selectedTab: selectedTab, selectedShelter: selectedShelter)
            .ignoresSafeArea()
    }
}

struct FloatingPanelView<Parent: View>: UIViewControllerRepresentable {
    @ViewBuilder var parent: Parent
    @Binding var selectedTab: Int
    @Binding var selectedShelter: Shelter?
    
    func makeUIViewController(context: Context) -> UIHostingController<Parent> {
        let hostingController = UIHostingController(rootView: parent)
        hostingController.view.backgroundColor = nil
        context.coordinator.setupFloatingPanel(hostingController, selectedTab: selectedTab, selectedShelter: selectedShelter)
        return hostingController
    }
    
    func updateUIViewController(
        _ uiViewController: UIHostingController<Parent>,
        context: Context
    ) {
        context.coordinator.updateContent(selectedTab: selectedTab, selectedShelter: selectedShelter)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }
    
    class Coordinator: NSObject, FloatingPanelControllerDelegate {
        private let view: FloatingPanelView<Parent>
        private lazy var fpc = FloatingPanelController()
        
        init(view: FloatingPanelView<Parent>) {
            self.view = view
        }
        
        func setupFloatingPanel(_ parentViewController: UIViewController, selectedTab: Int, selectedShelter: Shelter?) {
            fpc.delegate = self
            
            // パネルレイアウトを設定
            fpc.layout = MyFloatingPanelLayout()
            
            // パネルの見た目を設定
            let appearance = SurfaceAppearance()
            appearance.cornerRadius = 16.0
            fpc.surfaceView.appearance = appearance
            
            // スクロール連動の設定
            fpc.isRemovalInteractionEnabled = false  // スワイプでの削除を無効化
            fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = false  // 背景タップでの閉じるを無効化
            
            // 内容を更新
            updateContent(selectedTab: selectedTab, selectedShelter: selectedShelter)
            
            // パネルを追加
            fpc.addPanel(toParent: parentViewController, animated: false)
        }
        
        func updateContent(selectedTab: Int, selectedShelter: Shelter?) {
            let contentView: UIViewController
            
            switch selectedTab {
            case 0:
                if let shelter = selectedShelter {
                    let homeContentView = HomeContentView(shelter: shelter)
                    contentView = UIHostingController(rootView: homeContentView)
                    
                    // スクロールビューとの連動を設定するため、画面が表示された後に処理
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.findScrollViewAndSetupTracking(in: contentView.view)
                    }
                } else {
                    contentView = UIHostingController(rootView: Text("避難所が選択されていません"))
                }
            case 1:
                contentView = UIHostingController(rootView: SafetyCheckContentView())
            case 2:
                contentView = UIHostingController(rootView: EmergencyBagContentView())
            case 3:
                contentView = UIHostingController(rootView: EmergencyMemoContentView())
            case 4:
                contentView = UIHostingController(rootView: MenuContentView())
            default:
                contentView = UIHostingController(rootView: Text("不明なタブが選択されました"))
            }

            fpc.set(contentViewController: contentView)
        }
        
        // ビュー階層からスクロールビューを探して追跡設定
        private func findScrollViewAndSetupTracking(in view: UIView) {
            // UIScrollViewを探す
            for subview in view.subviews {
                // ScrollViewを見つけたら追跡を設定
                if let scrollView = subview as? UIScrollView {
                    fpc.track(scrollView: scrollView)
                    return
                }
                
                // 子ビューを再帰的に探索
                if subview.subviews.count > 0 {
                    findScrollViewAndSetupTracking(in: subview)
                }
            }
        }
        
        // FloatingPanelControllerDelegate
        func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
            // 状態変更時の処理
        }
        
        final class MyFloatingPanelLayout: FloatingPanelLayout {
            let position: FloatingPanelPosition = .bottom
            let initialState: FloatingPanelState = .tip
            
            var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
                return [
                    .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
                    .half: FloatingPanelLayoutAnchor(absoluteInset: 220.0, edge: .bottom, referenceGuide: .safeArea),
                    .tip: FloatingPanelLayoutAnchor(absoluteInset: 120.0, edge: .bottom, referenceGuide: .safeArea),
                ]
            }
            
            func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
                return 0.0 // 背景の暗さ
            }
        }
    }
}
