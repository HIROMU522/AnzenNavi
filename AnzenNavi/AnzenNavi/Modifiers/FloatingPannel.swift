//
//  FloatingPannel.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/09.
//

import SwiftUI
import UIKit
import FloatingPanel

// View extension to add FloatingPanel modifier
extension View {
    public func floatingPanel(selectedTab: Binding<Int>) -> some View {
        FloatingPanelView(parent: { self }, selectedTab: selectedTab)
            .ignoresSafeArea()
    }
}

struct FloatingPanelView<Parent: View>: UIViewControllerRepresentable {
    @ViewBuilder var parent: Parent
    @Binding var selectedTab: Int  // タブの選択状態をバインディングで受け取る

    public func makeUIViewController(context: Context) -> UIHostingController<Parent> {
        let hostingController = UIHostingController(rootView: parent)
        hostingController.view.backgroundColor = nil
        context.coordinator.setupFloatingPanel(hostingController, selectedTab: selectedTab) // 初期表示の設定
        return hostingController
    }

    public func updateUIViewController(
        _ uiViewController: UIHostingController<Parent>,
        context: Context
    ) {
        context.coordinator.updateContent(selectedTab: selectedTab) // タブ変更に応じて内容を更新
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    final class Coordinator {
        private let view: FloatingPanelView<Parent>
        private lazy var fpc = FloatingPanelController()

        init(view: FloatingPanelView<Parent>) {
            self.view = view
        }

        func setupFloatingPanel(_ parentViewController: UIViewController, selectedTab: Int) {
            fpc.layout = MyFloatingPanelLayout()
            updateContent(selectedTab: selectedTab)
            fpc.addPanel(toParent: parentViewController, animated: false)
        }

        // タブ選択に応じて FloatingPanel の内容を更新するメソッド
        func updateContent(selectedTab: Int) {
            // タブごとに異なる SwiftUI View を UIViewController としてラップしてセットする
            let contentView: UIViewController

            switch selectedTab {
            case 0:
                contentView = UIHostingController(rootView: HomeContentView())
            case 1:
                contentView = UIHostingController(rootView: MenuContentView())
            case 2:
                contentView = UIHostingController(rootView: ChecklistContentView())
            case 3:
                contentView = UIHostingController(rootView: ShoppingContentView())
            default:
                contentView = UIHostingController(rootView: HomeContentView())
            }

            fpc.set(contentViewController: contentView)
        }
    }

    final class MyFloatingPanelLayout: FloatingPanelLayout {
        let position: FloatingPanelPosition = .bottom
        let initialState: FloatingPanelState = .tip
        let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 80.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
