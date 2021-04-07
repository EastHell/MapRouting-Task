//
//  ViewController.swift
//  MapRouting-Task
//
//  Created by Александр Шушков on 05.04.2021.
//

import UIKit
import MapKit

class ViewController: UIViewController{
    
    //hardcoded Innopolis
    let initialLocation = CLLocation(latitude: 55.751716, longitude: 48.74731)
    
    lazy var mapView: MKMapView = {
        
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        return mapView
    }()
    
    weak var newAnnotation: MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.centerToLocation(initialLocation)
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func longPressAction(_ sender: UILongPressGestureRecognizer) {
        
        let pressLocation = sender.location(in: mapView)
        let offsetLocation = CGPoint(x: pressLocation.x, y: pressLocation.y - 32)
        let coordinate = mapView.convert(offsetLocation, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Point"
            annotation.subtitle = "\(coordinate.latitude), \(coordinate.longitude)"
            
            newAnnotation = annotation
            
            mapView.addAnnotation(annotation)
        }
        if sender.state == .changed {

            if let annotation = newAnnotation {

                annotation.coordinate = coordinate
            }
        }
        if sender.state == .ended {
            
            newAnnotation = nil
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isKind(of: MKUserLocation.self) { return nil }

        let pinIdentifier = "pinIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier)

        if let annotationView = annotationView {

            annotationView.annotation = annotation
        } else {

            let newAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            newAnnotationView.animatesDrop = true
            newAnnotationView.isDraggable = true
            newAnnotationView.canShowCallout = true
            annotationView = newAnnotationView
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        view.set
    }
}

private extension MKMapView {
    
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
