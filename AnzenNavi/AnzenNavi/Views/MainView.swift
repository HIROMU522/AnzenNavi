import SwiftUI
import UIKit


struct MainView: View {
    var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)  
            FloatingPanelWrapper()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// FloatingPanelをSwiftUIでラップする
struct FloatingPanelWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FloatingPanelController {
        return FloatingPanelController()
    }

    func updateUIViewController(_ uiViewController: FloatingPanelController, context: Context) {
    }
}

