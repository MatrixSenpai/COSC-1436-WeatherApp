//
//  WeatherAPI.swift
//  WeatherAPI
//
//  Created by Mason Phillips on 8/31/21.
//

import Foundation
import CoreLocation

protocol WeatherResponseDelegate {
    func didReturnWeather(with response: WeatherResponse)
    func didReturnForecast(with response: ForecastResponse)
    func didReturnSearchResults(with response: SearchResults)
    
    func errorDidOccur(_ error: Error)
}

class API {
    private let baseURL: URL = URL(string: "https://api.weatherapi.com/v1")!
    private let apiKey: String = ProcessInfo.processInfo.environment["API_KEY"]!
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    var delegate: WeatherResponseDelegate?
    
    enum APIError: Error {
        case noResponse
        case invalidResponseFormat
        case invalidStatusCode(_ status: Int), emptyBody
    }
    
    init() {}
    
    private func handleCurrentWeather(response: WeatherResponse?, error: Error?) {
        guard error == nil else { return delegate?.errorDidOccur(error!) ?? () }
        delegate?.didReturnWeather(with: response!)
    }
    func currentWeatherFor(zip: String) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/current.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: zip)
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleCurrentWeather(response:error:))
    }
    func currentWeatherFor(city: String, state: String) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/current.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(city)%20\(state)")
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleCurrentWeather(response:error:))
    }
    func currentWeatherFor(location: CLLocationCoordinate2D) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/current.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(location.latitude),\(location.longitude)")
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleCurrentWeather(response:error:))
    }
    
    private func handleForecast(response: ForecastResponse?, error: Error?) {
        guard error == nil else { return delegate?.errorDidOccur(error!) ?? () }
        delegate?.didReturnForecast(with: response!)
    }
    func forecastFor(zip: String, days: Int = 1) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/forecast.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: zip),
            URLQueryItem(name: "days", value: "\(days)"),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleForecast(response:error:))
    }
    func forecastFor(city: String, state: String, days: Int = 1) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/forecast.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(city)%20\(state)"),
            URLQueryItem(name: "days", value: "\(days)"),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleForecast(response:error:))
    }
    func forecastFor(location: CLLocationCoordinate2D, days: Int = 1) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/forecast.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(location.latitude),\(location.longitude)"),
            URLQueryItem(name: "days", value: "\(days)"),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleForecast(response:error:))
    }
    
    private func handleSearch(response: SearchResults?, error: Error?) {
        guard error == nil else { return delegate?.errorDidOccur(error!) ?? () }
        delegate?.didReturnSearchResults(with: response!)
    }
    func search(query: String) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/search.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query)
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleSearch(response:error:))
    }
    
    private func fetchWeather<T: Decodable>(_ request: URLRequest, callback: @escaping ((_ response: T?, _ error: Error?) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    callback(object, nil)
                } catch {
                    callback(nil, error)
                }
            } else if let response = response as? HTTPURLResponse {
                if 200..<300 ~= response.statusCode {
                    callback(nil, APIError.emptyBody)
                } else {
                    callback(nil, APIError.invalidStatusCode(response.statusCode))
                }
            } else if let error = error {
                callback(nil, error)
            } else {
                callback(nil, APIError.noResponse)
            }
        }.resume()
    }
}

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Float
    let lon: Float
    let tz_id: String
    let localtime_epoch: UInt64
    let localtime: String
}
struct CurrentWeather: Decodable {
    let last_updated_epoch: UInt64
    let last_updated: String
    let temp_c: Float
    let temp_f: Float
    let is_day: Int
    let condition: Condition
    let wind_mph: Float
    let wind_kph: Float
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Float
    let pressure_in: Float
    let precip_mm: Float
    let precip_in: Float
    let humidity: Int
    let cloud: Int
    let feelslike_c: Float
    let feelslike_f: Float
    let vis_km: Float
    let vis_miles: Float
    let uv: Float
    let gust_mph: Float
    let gust_kph: Float
    
    struct Condition: Decodable {
        let text: String
        let icon: String
        let code: Int
    }
}
struct WeatherResponse: Decodable {
    let location: Location
    let current : CurrentWeather
}
struct ForecastResponse: Decodable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
    
    struct Forecast: Decodable {
        let forecastday: [ForecastDay]
        
        struct ForecastDay: Decodable {
            let date: String
            let date_epoch: UInt64
            let day: Day
            let astro: Astro
            let hour: [Hour]
            
            struct Day: Decodable {
                let maxtemp_c: Float
                let maxtemp_f: Float
                let mintemp_c: Float
                let mintemp_f: Float
                let avgtemp_c: Float
                let avgtemp_f: Float
                let maxwind_mph: Float
                let maxwind_kph: Float
                let totalprecip_mm: Float
                let totalprecip_in: Float
                let avgvis_km: Float
                let avgvis_miles: Float
                let avghumidity: Float
                let daily_will_it_rain: Int
                let daily_chance_of_rain: Int
                let daily_will_it_snow: Int
                let daily_chance_of_snow: Int
                let condition: CurrentWeather.Condition
                let uv: Float
            }
            
            struct Astro: Decodable {
                let sunrise: String
                let sunset: String
                let moonrise: String
                let moonset: String
                let moon_phase: String
                let moon_illumination: String
            }
            
            struct Hour: Decodable {
                let time_epoch: UInt64
                let time: String
                let temp_c: Float
                let temp_f: Float
                let is_day: Int
                let condition: CurrentWeather.Condition
                let wind_mph: Float
                let wind_kph: Float
                let wind_degree: Int
                let wind_dir: String
                let pressure_mb: Float
                let pressure_in: Float
                let precip_mm: Float
                let precip_in: Float
                let humidity: Int
                let cloud: Int
                let feelslike_c: Float
                let feelslike_f: Float
                let windchill_c: Float
                let windchill_f: Float
                let heatindex_c: Float
                let heatindex_f: Float
                let dewpoint_c: Float
                let dewpoint_f: Float
                let will_it_rain: Int
                let chance_of_rain: Int
                let will_it_snow: Int
                let chance_of_snow: Int
                let vis_km: Float
                let vis_miles: Float
                let gust_mph: Float
                let gust_kph: Float
                let uv: Float
            }
        }
    }
}

typealias SearchResults = Array<SearchCompletion>
struct SearchCompletion: Decodable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
