import SwiftUI
import MapKit

struct MainView: View {
    var body: some View {
        // MapKitを使用して地図を表示
        Map()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

