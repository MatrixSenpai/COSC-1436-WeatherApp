//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mason Phillips on 8/26/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    let api: API = .shared
    let locationManager = CLLocationManager()
    
    var savedLocation: SearchCompletion?
    var hourlyForecast: [HourByHourCollectionViewCell.Item] = []
    
    var defaults: UserDefaults {
        return UserDefaults.standard
    }

    @IBOutlet weak var conditionIcon: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel : UILabel!
    @IBOutlet weak var location : UILabel!
    
    @IBOutlet weak var byHourCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.delegate = self
        byHourCollection.delegate = self
        byHourCollection.dataSource = self
        locationManager.delegate = self
        
        tempLabel.text = ""
        highLabel.text = ""
        lowLabel.text  = ""
        location.text  = "Loading..."
        
        byHourCollection.register(UINib(nibName: "HourByHourCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "hourlyCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        api.delegate = self
        
        if let location = savedLocation {
            api.forecastFor(location: location.coordinates)
        } else {
            locationManager.requestLocation()
        }
    }
    
    func receiveLocation(_ location: SearchCompletion) {
        self.savedLocation = location
    }
    
    func useCurrentLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            api.forecastFor(location: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: WeatherResponseDelegate {
    func didReturnWeather(with response: WeatherResponse) {}
    
    func didReturnForecast(with response: ForecastResponse) {
        hourlyForecast = response.forecast.forecastday.first?.hour ?? []
        self.byHourCollection.reloadData()
        
        conditionIcon.image = response.current.conditionImage
        
        let tempText = String(format: "%.0f° F", response.current.temp_f)
        tempLabel.text = tempText
        
        let forecast = response.forecast.forecastday[0]
        
        highLabel.text = "\(forecast.day.maxtemp_f)° F"
        lowLabel.text  = "\(forecast.day.mintemp_f)° F"
        
        location.text = "\(response.location.name), \(response.location.region)"
    }
    
    func didReturnSearchResults(with response: SearchResults) {}
    
    func errorDidOccur(_ error: Error) {
        print(error)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { hourlyForecast.count }
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath)
        
        (cell as? HourByHourCollectionViewCell)?.configure(hourlyForecast[indexPath.row])
        
        return cell
    }
}
