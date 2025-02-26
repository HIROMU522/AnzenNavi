//
//  HomeContentView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI

struct HomeContentView: View {
    var shelter: Shelter
    @State private var isFavorite: Bool = false
    @State private var showingShareSheet = false
    @State private var showAllFacilities = false
    @Environment(\.colorScheme) private var colorScheme
    
    // 全ての設備タイプ
    private let allFacilities = Shelter.Facility.allCases
    
    // 表示する設備（初期は6つまで）
    private var displayedFacilities: [Shelter.Facility] {
        showAllFacilities ? allFacilities : Array(allFacilities.prefix(6))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダーセクション
            headerSection
            
            // スクロール可能なコンテンツ
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // 各セクション
                    sectionContainer {
                        basicInfoSection
                    }
                    
                    sectionContainer {
                        statusSection
                    }
                    
                    sectionContainer {
                        facilitiesSection
                    }
                    
                    sectionContainer {
                        disastersSection
                    }
                    
                    sectionContainer {
                        routeButtonsSection
                    }
                    
                    if let notes = shelter.notes, !notes.isEmpty {
                        sectionContainer {
                            notesSection(notes)
                        }
                    }
                    
                    lastUpdatedSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .id("HomeContentScrollView") // スクロールビューの特定用ID
        }
        .sheet(isPresented: $showingShareSheet) {
            shareSheet()
        }
        .onAppear {
            checkFavoriteStatus()
        }
    }
    
    // セクションコンテナ（一貫したデザインを適用するためのラッパー）
    private func sectionContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(shelter.name)
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: {
                    toggleFavorite()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 22))
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
                .padding(.horizontal, 4)
                
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            
            Text(shelter.address)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            // 指定避難所タグを右上に表示
            if shelter.designated_shelter {
                HStack {
                    Spacer()
                    Text("指定避難所")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red)
                        )
                }
                .padding(.top, -32) // ヘッダーに重ねて表示
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24) // より広いスペースを確保
        .padding(.bottom, 16) // 下側にもスペースを追加
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : .white)
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("基本情報")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            // アクセス情報（情報がない場合は「--」を表示）
            infoRow(
                icon: "figure.walk",
                title: "最寄り駅からのアクセス",
                value: shelter.accessInfo ?? "--"
            )
            
            // 電話番号（情報がない場合は「--」を表示）
            infoRow(
                icon: "phone.fill",
                title: "連絡先",
                value: shelter.phoneNumber ?? "--",
                isPhone: shelter.phoneNumber != nil
            )
        }
    }
    
    private func infoRow(icon: String, title: String, value: String, isPhone: Bool = false) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isPhone {
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            if let url = URL(string: "tel://\(value.replacingOccurrences(of: "-", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        }
                } else {
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("施設情報")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            HStack(spacing: 12) {
                // ステータス
                statusInfoBox(
                    title: "ステータス",
                    value: shelter.status?.rawValue ?? "状況不明",
                    statusColor: shelter.status != nil ? statusColor(for: shelter.status!) : .gray
                )
                
                // 収容人数
                statusInfoBox(
                    title: "収容可能人数",
                    value: shelter.capacity != nil ? "\(shelter.capacity!)名" : "--"
                )
                
                // 現在の避難者数
                statusInfoBox(
                    title: "現在の避難者数",
                    value: "--"
                )
            }
        }
    }
    
    private func statusInfoBox(title: String, value: String, statusColor: Color? = nil) -> some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 4) {
                if let color = statusColor {
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)
                }
                Text(value)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private var facilitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("利用可能な設備")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // もっと見る / 閉じる ボタン
                Button(action: {
                    withAnimation {
                        showAllFacilities.toggle()
                    }
                }) {
                    Text(showAllFacilities ? "閉じる" : "もっと見る")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(displayedFacilities) { facility in
                    facilityBox(facility: facility)
                }
            }
        }
    }
    
    private func facilityBox(facility: Shelter.Facility) -> some View {
        let isAvailable = shelter.isFacilityAvailable(facility)
        
        return VStack(spacing: 4) {
            Image(systemName: facility.iconName)
                .font(.system(size: 20))
                .foregroundColor(isAvailable ? facility.displayColor : .gray)
            
            Text(facility.rawValue)
                .font(.caption)
                .foregroundColor(isAvailable ? .primary : .secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isAvailable ? facility.displayColor.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
    
    private var disastersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("対応災害")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(shelter.disasters, id: \.self) { disaster in
                        disasterTag(disaster: disaster)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    private func disasterTag(disaster: String) -> some View {
        Text(disaster)
            .font(.system(size: 14))
            .foregroundColor(disasterTextColor(for: disaster))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 34) // 高さを固定して統一
            .background(
                Capsule()
                    .stroke(disasterColor(for: disaster), lineWidth: 1)
                    .background(
                        Capsule()
                            .fill(disasterColor(for: disaster).opacity(0.1))
                    )
            )
    }
    
    private var routeButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ルート案内")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            HStack(spacing: 16) {
                Button(action: {
                    openInAppleMaps()
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 18))
                        Text("Apple Maps")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    openInGoogleMaps()
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                        Text("Google Maps")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("追加情報")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            Text(notes)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
    
    private var lastUpdatedSection: some View {
        HStack {
            Spacer()
            Text("情報更新日: \(shelter.lastUpdated != nil ? formattedDate(shelter.lastUpdated!) : "--")")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper Methods
    
    private func statusColor(for status: Shelter.ShelterStatus) -> Color {
        switch status {
        case .open:
            return .green
        case .closed:
            return .gray
        case .full:
            return .red
        case .limited:
            return .orange
        case .unknown:
            return .gray
        }
    }
    
    private func disasterTextColor(for disaster: String) -> Color {
        // より読みやすいテキスト色
        return disasterColor(for: disaster)
    }
    
    private func disasterColor(for disaster: String) -> Color {
        switch disaster {
        case "地震":
            return Color.orange
        case "津波":
            return Color.blue
        case "洪水":
            return Color.cyan
        case "崖崩れ":
            return Color.brown
        case "土石流":
            return Color.brown
        case "火災":
            return Color.red
        default:
            return Color.purple
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func toggleFavorite() {
        isFavorite = FavoriteSheltersManager.shared.toggleFavorite(shelter: shelter)
    }
    
    private func checkFavoriteStatus() {
        isFavorite = FavoriteSheltersManager.shared.isFavorite(shelter: shelter)
    }
    
    private func openInAppleMaps() {
        let latitude = shelter.latitude
        let longitude = shelter.longitude
        let name = shelter.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "https://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=w&t=m&q=\(name)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInGoogleMaps() {
        let latitude = shelter.latitude
        let longitude = shelter.longitude
        let name = shelter.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Google Mapsアプリがインストールされているか確認
        if let url = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(url) {
            // Google Mapsアプリを開く
            let mapUrl = URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=walking&q=\(name)")!
            UIApplication.shared.open(mapUrl)
        } else {
            // ウェブブラウザでGoogle Mapsを開く
            let mapUrl = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)&travelmode=walking&q=\(name)")!
            UIApplication.shared.open(mapUrl)
        }
    }
    
    // シェアシートの実装
    private func shareSheet() -> some View {
        let shareText = """
        避難所情報: \(shelter.name)
        住所: \(shelter.address)
        対応災害: \(shelter.disasters.joined(separator: ", "))
        指定避難所: \(shelter.designated_shelter ? "はい" : "いいえ")
        """
        
        return ActivityViewController(activityItems: [shareText])
    }
    
    // ActivityViewControllerの定義
    struct ActivityViewController: UIViewControllerRepresentable {
        var activityItems: [Any]
        var applicationActivities: [UIActivity]? = nil
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: applicationActivities
            )
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView(shelter: Shelter.sample())
    }
}
