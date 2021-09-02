//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mason Phillips on 8/26/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    let api = API()
    let locationManager = CLLocationManager()

    @IBOutlet weak var conditionIcon: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel : UILabel!
    @IBOutlet weak var location : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        tempLabel.text = ""
        highLabel.text = ""
        lowLabel.text  = ""
        location.text  = "Loading..."
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
        self.errorDidOccur(error)
    }
}

extension ViewController: WeatherResponseDelegate {
    func didReturnWeather(with response: WeatherResponse) {}
    func didReturnForecast(with response: ForecastResponse) {
        tempLabel.text = "\(response.current.temp_f)° F"
        highLabel.text = "H: \(response.forecast.forecastday.first!.day.maxtemp_f)° F"
        lowLabel.text  = "L: \(response.forecast.forecastday.first!.day.mintemp_f)° F"
        location.text  = "\(response.location.name), \(response.location.region)"
        
        conditionIcon.image = response.current.conditionImage ?? UIImage(systemName: "sun.fill")
    }
    func didReturnSearchResults(with response: SearchResults) {}
    
    func errorDidOccur(_ error: Error) {
        let message: String
        if let error = error as? WeatherAPIError {
            message = error.message
        } else {
            message = error.localizedDescription
        }
        let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
