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
    
    @IBOutlet weak var epochLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.forecastFor(city: "Truth or Consequences", state: "NM")
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        
        tempLabel.text = ""
        highLabel.text = ""
        lowLabel.text  = ""
        location.text  = "Loading..."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        api.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchController", let controller = segue.destination as? SearchTableViewController {
            controller.api = self.api
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestLocation()
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
        conditionIcon.image = response.current.conditionImage
        
        let tempText = String(format: "%.0f° F", response.current.temp_f)
        tempLabel.text = tempText
        
        let forecast = response.forecast.forecastday[0]
        
        highLabel.text = "\(forecast.day.maxtemp_f)° F"
        lowLabel.text  = "\(forecast.day.mintemp_f)° F"
        
        location.text = "\(response.location.name), \(response.location.region)"
        
        epochLabel.text = String(format: "%d", forecast.date_epoch)
    }
    
    func didReturnSearchResults(with response: SearchResults) {}
    
    func errorDidOccur(_ error: Error) {
        print(error)
    }
}
