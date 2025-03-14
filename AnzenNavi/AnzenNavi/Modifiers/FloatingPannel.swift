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
            
            fpc.layout = MyFloatingPanelLayout()
            
            let appearance = SurfaceAppearance()
            appearance.cornerRadius = 16.0
            fpc.surfaceView.appearance = appearance
            
            fpc.isRemovalInteractionEnabled = false
            fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = false
            
            updateContent(selectedTab: selectedTab, selectedShelter: selectedShelter)
            
            fpc.addPanel(toParent: parentViewController, animated: false)
        }
        
        func updateContent(selectedTab: Int, selectedShelter: Shelter?) {
            let contentView: UIViewController
            
            switch selectedTab {
            case 0:
                if let shelter = selectedShelter {
                    let homeContentView = HomeContentView(shelter: shelter)
                    contentView = UIHostingController(rootView: homeContentView)
                    
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
        
        private func findScrollViewAndSetupTracking(in view: UIView) {
            for subview in view.subviews {
                if let scrollView = subview as? UIScrollView {
                    fpc.track(scrollView: scrollView)
                    return
                }
                
                if subview.subviews.count > 0 {
                    findScrollViewAndSetupTracking(in: subview)
                }
            }
        }
        
        func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
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
                return 0.0
            }
        }
    }
}
