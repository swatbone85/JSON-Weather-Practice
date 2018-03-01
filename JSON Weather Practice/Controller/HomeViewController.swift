//
//  ViewController.swift
//  JSON Weather Practice
//
//  Created by Thomas Swatland on 03/10/2017.
//  Copyright © 2017 Thomas Swatland. All rights reserved.
//

import UIKit
import CoreLocation

let temperatureView = UIView()
let detailView = UIView()

var userLat = Double()
var userLong = Double()
var userLocation = String()

let cellId = "cellId"

class HomeViewController: UIViewController, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        let userCoordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        
        userLat = userCoordinates.latitude
        userLong = userCoordinates.longitude
        let clLocation = CLLocation(latitude: userLat, longitude: userLong)
        geoCoder.reverseGeocodeLocation(clLocation) { (placemarks, error) in
            if error != nil {
                print("Geocoding error: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                if pm.locality != nil {
                    self.locationLabel.text = pm.locality!
                } else {
                    self.locationLabel.text = "Could not find location"
                }
            }
        }
        
        getJSONData()
        locationManager.stopUpdatingLocation()
    }

    fileprivate func getUserLocation() {
        
//        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserLocation()
        
        setupGradientBackgroundColor()
    }

    let currentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [temperatureView, detailView])
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let summaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weatherIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.text = "DETAILS"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dividerLine: UILabel = {
        let line = UILabel()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let humidityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let windSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 85)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let attributeImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "poweredby-oneline-darkbackground")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    func getJSONData() {

        guard let url = URL(string: "https://api.darksky.net/forecast/ce77365528e4e8db7af0c80a978fbbe7/\(userLat),\(userLong)") else { return }

        URLSession.shared.dataTask(with: url) { (data, response, err) in

        guard let data = data else { return }

            do {
                let weather = try JSONDecoder().decode(Forecast.self, from: data)
                DispatchQueue.main.async {
                    self.summaryLabel.text = weather.currently.summary
                    self.weatherIcon.image = UIImage(named: weather.currently.icon)
                    self.tempLabel.text = "\(self.tempInCelcius(weather.currently.temperature))°"
                    self.humidityLabel.text = "Humidity: \(Int(weather.currently.humidity * 100))%"
                    self.windSpeedLabel.text = "Wind speed: \(weather.currently.windSpeed)m/s"
                    self.addSubviews()
                    self.addConstraints()
                }
            } catch let jsonErr {
                print("JSON error: ",jsonErr)
                
            }
        }.resume()
    }
    
    fileprivate func setupGradientBackgroundColor() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.blue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
    }
    
    func addSubviews() {

        view.addSubview(locationLabel)
        view.addSubview(summaryLabel)
        view.addSubview(weatherIcon)
        view.addSubview(currentStackView)
        view.addSubview(attributeImage)
        
        temperatureView.addSubview(tempLabel)
        
        detailView.addSubview(detailsLabel)
        detailView.addSubview(dividerLine)
        detailView.addSubview(humidityLabel)
        detailView.addSubview(windSpeedLabel)
    }
    
    func addConstraints() {
        
        locationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        summaryLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20).isActive = true
        summaryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        summaryLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        weatherIcon.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20).isActive = true
        weatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        weatherIcon.heightAnchor.constraint(equalToConstant: 200).isActive = true
        weatherIcon.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        currentStackView.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor).isActive = true
        currentStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        currentStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        currentStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        detailsLabel.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 10).isActive = true
        detailsLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor, constant: 2).isActive = true
        detailsLabel.heightAnchor.constraint(equalToConstant: 17).isActive = true
        detailsLabel.rightAnchor.constraint(equalTo: detailView.rightAnchor).isActive = true
        
        dividerLine.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 2).isActive = true
        dividerLine.leftAnchor.constraint(equalTo: detailsLabel.leftAnchor, constant: 4).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        humidityLabel.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 4).isActive = true
        humidityLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor, constant: 4).isActive = true
        humidityLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        windSpeedLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 4).isActive = true
        windSpeedLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor, constant: 4).isActive = true
        windSpeedLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        tempLabel.topAnchor.constraint(equalTo: temperatureView.topAnchor).isActive = true
        tempLabel.rightAnchor.constraint(equalTo: temperatureView.rightAnchor, constant: -4).isActive = true
        
        attributeImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        attributeImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        attributeImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    func tempInCelcius(_ temp: Double) -> Int {
        let result = (temp - 32) / 1.8
        return Int(result)
    }
    
    func metersPerSecond(_ speed: Double) -> Double {
        let speedInMetersPerHour = speed * 1609.34
        let speedPerSecond = speedInMetersPerHour / 3600
        return speedPerSecond
    }
}

