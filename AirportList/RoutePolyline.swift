//
//  RoutePolyline.swift
//  AirportList
//
//  Created by Kyoko Hobo on 2025/07/31.
//

import SwiftUI
import MapKit

struct RoutePolyline: UIViewRepresentable {
    let from: Airport
    let to: Airport

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false
        mapView.delegate = context.coordinator

        let coord1 = CLLocationCoordinate2D(latitude: from.latitude, longitude: from.longitude)
        let coord2 = CLLocationCoordinate2D(latitude: to.latitude, longitude: to.longitude)

        let polyline = MKGeodesicPolyline(coordinates: [coord1, coord2], count: 2)
        mapView.addOverlay(polyline)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        let coord1 = CLLocationCoordinate2D(latitude: from.latitude, longitude: from.longitude)
        let coord2 = CLLocationCoordinate2D(latitude: to.latitude, longitude: to.longitude)
        let polyline = MKGeodesicPolyline(coordinates: [coord1, coord2], count: 2)
        mapView.addOverlay(polyline)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
