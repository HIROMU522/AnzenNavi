import SwiftUI
import UIKit
import FloatingPanel

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)
                .floatingPanel(selectedTab: $selectedTab) 
            VStack {
                Spacer()
                MenuBarView(selectedTab: $selectedTab)
                    .frame(height: 50)
            }
        }
    }
}


