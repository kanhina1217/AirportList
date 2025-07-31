//
//  ContentView.swift
//  AirportList
//
//  Created by Kyoko Hobo on 2025/07/31.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.0, longitude: 135.0),
            span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        )
    )
    
    @State private var airports: [Airport] = []
    @State private var selectedAirport: Airport?
    @State private var selectedForRoute: [Airport] = []
    @State private var searchText: String = ""
    
    // 現在のズームレベルを取得
    var currentZoomLevel: Double {
        return 100 // デフォルト値を返す
    }
    
    var filteredAirports: [Airport] {
        if searchText.isEmpty {
            return []
        }
        return airports.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.iata.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            TextField("空港名またはIATAを検索", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            // 検索結果リスト
            if !filteredAirports.isEmpty {
                List(filteredAirports, id: \.id) { airport in
                    Button {
                        withAnimation {
                            position = .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: airport.latitude, longitude: airport.longitude),
                                    span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                                )
                            )
                            selectedAirport = airport
                            searchText = ""
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(airport.name) (\(airport.iata))")
                            Text("\(airport.city), \(airport.country)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 150)
            }
            
            // マップ表示
            Map(position: $position) {
                ForEach(airports) { airport in
                    Annotation(airport.iata, coordinate: CLLocationCoordinate2D(latitude: airport.latitude, longitude: airport.longitude)) {
                        VStack {
                            // ズームレベルが小さい時（より広範囲を表示している時）にIATAコードを表示
                            Text(airport.iata)
                                .font(.caption2)
                                .padding(4)
                                .background(.white.opacity(0.7))
                                .clipShape(Capsule())
                                .transition(.scale)
                            
                            Circle()
                                .fill(selectedForRoute.contains(airport) ? Color.red : Color.blue)
                                .frame(width: 10, height: 10)
                                .onTapGesture {
                                    selectedAirport = airport
                                    if !selectedForRoute.contains(airport) {
                                        if selectedForRoute.count < 2 {
                                            selectedForRoute.append(airport)
                                        } else {
                                            selectedForRoute = [selectedForRoute[1], airport]
                                        }
                                    }
                                }
                        }
                    }
                }
                
                // 大圏航路の表示
                if let polyline = routePolyline() {
                    polyline.stroke(.red, lineWidth: 2)
                }
            }
            .mapStyle(.standard)
            
            // 選択空港情報の表示
            if let airport = selectedAirport {
                VStack(spacing: 4) {
                    Text(airport.name)
                        .font(.headline)
                    Text("\(airport.city), \(airport.country)")
                    Text("IATA: \(airport.iata) / ICAO: \(airport.icao)")
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.95))
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding()
            }
        }
        .onAppear(perform: loadAirports)
    }
    
    // 空港データ読み込み
    func loadAirports() {
        if let url = Bundle.main.url(forResource: "airports", withExtension: "json") {
            if let data = try? Data(contentsOf: url) {
                if let decoded = try? JSONDecoder().decode([Airport].self, from: data) {
                    airports = decoded.filter {
                        !$0.iata.isEmpty && $0.latitude != 0 && $0.longitude != 0
                    }
                }
            }
        }
    }
    
    // 大圏航路のPolyline生成
    func routePolyline() -> MapPolyline? {
        guard selectedForRoute.count == 2 else { return nil }
        let from = CLLocationCoordinate2D(latitude: selectedForRoute[0].latitude, longitude: selectedForRoute[0].longitude)
        let to = CLLocationCoordinate2D(latitude: selectedForRoute[1].latitude, longitude: selectedForRoute[1].longitude)
        return MapPolyline(coordinates: [from, to])
    }
}
