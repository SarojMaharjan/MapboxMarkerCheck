//
//  ViewController.swift
//  MapboxTest
//
//  Created by Saroj Maharjan on 26/07/2022.
//

import UIKit
import MapboxNavigation
import MapboxCoreNavigation
import MapboxMaps
import CoreLocation

class ViewController: UIViewController {
    
    private lazy var navigationMapView: NavigationMapView = {
        let view = NavigationMapView(frame: self.view.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    private let toggleButton = UIButton()
    private let passiveLocationManager = PassiveLocationManager()
    private lazy var passiveLocationProvider = PassiveLocationProvider(locationManager: passiveLocationManager)
    private var location: CLLocation! = nil
    
    private var isSnappingEnabled: Bool = false {
        didSet {
            toggleButton.backgroundColor = isSnappingEnabled ? .blue : .darkGray
            let locationProvider: LocationProvider = isSnappingEnabled ? passiveLocationProvider : AppleLocationProvider()
            navigationMapView.mapView.location.overrideLocationProvider(with: locationProvider)
            passiveLocationProvider.delegate = self
            passiveLocationProvider.startUpdatingLocation()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpNavigationMapView()
        setupSnappingToggle()
    }
    
    private func setUpNavigationMapView() {
        navigationMapView.userLocationStyle = .puck2D()
        
        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView)
        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
        navigationViewportDataSource.followingMobileCamera.zoom = 17.0
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
        
        view.addSubview(navigationMapView)
    }
    
    private func setupSnappingToggle() {
        toggleButton.setTitle("Snap to Roads", for: .normal)
        toggleButton.layer.cornerRadius = 5
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        isSnappingEnabled = false
        toggleButton.addTarget(self, action: #selector(toggleSnapping), for: .touchUpInside)
        view.addSubview(toggleButton)
        toggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        toggleButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        toggleButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        toggleButton.sizeToFit()
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    }
    
    @objc private func toggleSnapping() {
        isSnappingEnabled.toggle()
    }
    
    func addMarkers() {
        guard location != nil else { return }
        let coordinateSets: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: location!.coordinate.latitude + 0.0001, longitude: location!.coordinate.longitude - 0.0001),
            CLLocationCoordinate2D(latitude: location!.coordinate.latitude - 0.0001, longitude: location!.coordinate.longitude - 0.0001),
            CLLocationCoordinate2D(latitude: location!.coordinate.latitude - 0.0001, longitude: location!.coordinate.longitude + 0.0001),
            CLLocationCoordinate2D(latitude: location!.coordinate.latitude + 0.0002, longitude: location!.coordinate.longitude - 0.0002),
            CLLocationCoordinate2D(latitude: location!.coordinate.latitude - 0.0002, longitude: location!.coordinate.longitude + 0.0002)
        ]
        var annotations: [PointAnnotation] = []
        for coordinate in coordinateSets {
            let markerLocation = coordinate
            // Initialize a point annotation with a geometry ("coordinate" in this case)
            var pointAnnotation = PointAnnotation(coordinate: markerLocation)
            // Make the annotation show a red pin
            pointAnnotation.image = .init(image: UIImage(named: "polygon2")!, name: "polygon2")
            pointAnnotation.iconAnchor = .bottom
            annotations.append(pointAnnotation)
        }
        // Create the `PointAnnotationManager` which will be responsible for handling this annotation
        let pointAnnotationManager = navigationMapView.mapView.annotations.makePointAnnotationManager()

        // Add the annotation to the manager in order to render it on the map.
        pointAnnotationManager.annotations = annotations
    }
}
extension ViewController: LocationProviderDelegate {
    func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.first
        addMarkers()
    }
    
    func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        
    }
    
    func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        
    }
    
    
}
