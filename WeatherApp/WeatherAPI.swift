//
//  WeatherAPI.swift
//  WeatherAPI
//
//  Created by Mason Phillips on 8/31/21.
//

import Foundation

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
    let is_day: Bool
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
struct ForecastResponse: Decodable {}

protocol WeatherResponseDelegate {
    func didReturnWeather(with response: WeatherResponse)
    func didReturnForecast(with response: ForecastResponse)
    
    func errorDidOccur(_ error: Error)
}

class API {
    private let apiKey: String = ""
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    var delegate: WeatherResponseDelegate?
    
    enum APIError: Error {
        case noResponse
        case invalidResponseFormat
        case invalidStatusCode(_ status: Int), emptyBody
    }
    
    init() {}
    
    func currentWeatherFor(zip: String) {}
    func currentWeatherFor(city: String, state: String) {}
    func forecastFor(zip: String) {}
    func forecastFor(city: String, state: String) {}
    
    private func fetchWeather(_ request: URLRequest) {
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                if let object = try? self.decoder.decode(WeatherResponse.self, from: data) {
                    self.delegate?.didReturnWeather(with: object)
                } else if let object = try? self.decoder.decode(ForecastResponse.self, from: data) {
                    self.delegate?.didReturnForecast(with: object)
                } else {
                    self.delegate?.errorDidOccur(APIError.invalidResponseFormat)
                }
            } else if let response = response as? HTTPURLResponse {
                if 200..<300 ~= response.statusCode {
                    self.delegate?.errorDidOccur(APIError.emptyBody)
                } else {
                    self.delegate?.errorDidOccur(APIError.invalidStatusCode(response.statusCode))
                }
            } else if let error = error {
                self.delegate?.errorDidOccur(error)
            } else {
                self.delegate?.errorDidOccur(APIError.noResponse)
            }
        }.resume()
    }
}
