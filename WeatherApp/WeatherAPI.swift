//
//  WeatherAPI.swift
//  WeatherAPI
//
//  Created by Mason Phillips on 8/31/21.
//

import Foundation
import CoreLocation
import UIKit

protocol WeatherResponseDelegate {
    /// Called when the api receives a weather response
    func didReturnWeather(with response: WeatherResponse)
    /// Called when the api receieves a forecast response
    func didReturnForecast(with response: ForecastResponse)
    /// Called when the api receives a search response
    func didReturnSearchResults(with response: SearchResults)
    
    /// Called when an error occurs decoding the data, or when nothing comes back
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
        DispatchQueue.main.async { self.delegate?.didReturnWeather(with: response!) }
    }
    /**
    Retrieve the current weather for a specified zip code

     - Parameters:
        - zip: The zip code to search for
     */
    func currentWeatherFor(zip: String) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/current.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: zip)
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleCurrentWeather(response:error:))
    }
    /**
     Retrieve current weather for a specified city and state
     
     - Parameters:
        - city: The city to search for
        - state: The state to search for
     */
    func currentWeatherFor(city: String, state: String) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/current.json"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(city)%20\(state)")
        ]
        fetchWeather(URLRequest(url: components!.url!), callback: handleCurrentWeather(response:error:))
    }
    /**
     Retrieve current weather for a specified location (generally meant to be used with current location)
     
     - Parameters:
        - location: The coordinates to search for
     */
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
        DispatchQueue.main.async {
            self.delegate?.didReturnForecast(with: response!)
        }
    }
    /**
     Retrieve forecast for a specified zip code
     
     - Parameters:
        - zip: The zip to search for
        - days: An (optional) number of days to retrieve for. Defaults to 1
     */
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
    /**
     Retrieve forecast for specified city and state
  
     - Parameters:
        - city: The city to search for
        - state: The state to search for
        - days: An (optional) number of days to retrieve for. Defaults to 1
     */
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
    /**
     Retrieve forecast for specified coordinates (generally meant to be used with current location)
     
     - Parameters:
        - location: The coordinates to search for
        - days: An (optional) number of days to retrieve for. Defaults to 1
     */
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
        DispatchQueue.main.async {
            self.delegate?.didReturnSearchResults(with: response!)
        }
    }
    /**
     Search for a location by zip, coordinates, or city/state
     
     - Parameters:
        - query: The location to search for. Can be a zip, coordinate set, or city/state
     */
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
                    if let apiError = try? self.decoder.decode(WeatherAPIError.self, from: data) {
                        callback(nil, apiError)
                    } else {
                        callback(nil, error)
                    }
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

/// The location searched for
struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    /// latitude
    let lat: Float
    /// longitude
    let lon: Float
    /// The time zone identifier
    let tz_id: String
    /// The local time from the unix epoch
    let localtime_epoch: UInt64
    /// The local time as a string
    let localtime: String
}
struct CurrentWeather: Decodable {
    let last_updated_epoch: UInt64
    let last_updated: String
    let temp_c: Float
    let temp_f: Float
    /// Is day - 0 = night, 1 = day
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
    
    var conditionImage: UIImage? {
        return condition.icon(is_day)
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
                let condition: Condition
                let uv: Float
                
                var conditionImage: UIImage? {
                    return condition.icon(1)
                }
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
                
                var conditionImage: UIImage? {
                    return condition.icon(is_day)
                }
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

struct WeatherAPIError: Error, Decodable {
    let code: Int
    let message: String
}

enum Condition: Int, Decodable, CaseIterable {
    enum Keys: String, CodingKey {
        case text, icon, code
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        if let code = try? container.decode(Int.self, forKey: .code) {
            self = Self(rawValue: code) ?? ._1000
        } else {
            throw DecodingError.dataCorruptedError(forKey: .code, in: container, debugDescription: "Missing code for condition")
        }
    }
    
    func image(isDay: Int) -> UIImage? {
        let name = "\(isDay == 1 ? "day" : "night")_\(self.icon)"
        return UIImage(named: name)
    }
    
    case _1000 = 1000
    case _1003 = 1003
    case _1006 = 1006
    case _1009 = 1009
    case _1030 = 1030
    case _1063 = 1063
    case _1066 = 1066
    case _1069 = 1069
    case _1072 = 1072
    case _1087 = 1087
    case _1114 = 1114
    case _1117 = 1117
    case _1135 = 1135
    case _1147 = 1147
    case _1150 = 1150
    case _1153 = 1153
    case _1168 = 1168
    case _1171 = 1171
    case _1180 = 1180
    case _1183 = 1183
    case _1186 = 1186
    case _1189 = 1189
    case _1192 = 1192
    case _1195 = 1195
    case _1198 = 1198
    case _1201 = 1201
    case _1204 = 1204
    case _1207 = 1207
    case _1210 = 1210
    case _1213 = 1213
    case _1216 = 1216
    case _1219 = 1219
    case _1222 = 1222
    case _1225 = 1225
    case _1237 = 1237
    case _1240 = 1240
    case _1243 = 1243
    case _1246 = 1246
    case _1249 = 1249
    case _1252 = 1252
    case _1255 = 1255
    case _1258 = 1258
    case _1261 = 1261
    case _1264 = 1264
    case _1273 = 1273
    case _1276 = 1276
    case _1279 = 1279
    case _1282 = 1282
    
    var day: String {
        switch self {
        case ._1000: return "Sunny"
        case ._1003: return "Partly Cloudy"
        case ._1006: return "Cloudy"
        case ._1009: return "Overcast"
        case ._1030: return "Mist"
        case ._1063: return "Patchy rain nearby"
        case ._1066: return "Patchy snow nearby"
        case ._1069: return "Patchy sleet nearby"
        case ._1072: return "Patchy freezing drizzle nearby"
        case ._1087: return "Thundery outbreaks in nearby"
        case ._1114: return "Blowing snow"
        case ._1117: return "Blizzard"
        case ._1135: return "Fog"
        case ._1147: return "Freezing fog"
        case ._1150: return "Patchy light drizzle"
        case ._1153: return "Light drizzle"
        case ._1168: return "Freezing drizzle"
        case ._1171: return "Heavy freezing drizzle"
        case ._1180: return "Patchy light rain"
        case ._1183: return "Light rain"
        case ._1186: return "Moderate rain at times"
        case ._1189: return "Moderate rain"
        case ._1192: return "Heavy rain at times"
        case ._1195: return "Heavy rain"
        case ._1198: return "Light freezing rain"
        case ._1201: return "Moderate or heavy freezing rain"
        case ._1204: return "Light sleet"
        case ._1207: return "Moderate or heavy sleet"
        case ._1210: return "Patchy light snow"
        case ._1213: return "Light snow"
        case ._1216: return "Patchy moderate snow"
        case ._1219: return "Moderate snow"
        case ._1222: return "Patchy heavy snow"
        case ._1225: return "Heavy snow"
        case ._1237: return "Ice pellets"
        case ._1240: return "Light rain shower"
        case ._1243: return "Moderate or heavy rain shower"
        case ._1246: return "Torrential rain shower"
        case ._1249: return "Light sleet showers"
        case ._1252: return "Moderate or heavy sleet showers"
        case ._1255: return "Light snow showers"
        case ._1258: return "Moderate or heavy snow showers"
        case ._1261: return "Light showers of ice pellets"
        case ._1264: return "Moderate or heavy showers of ice pellets"
        case ._1273: return "Patchy light rain in area with thunder"
        case ._1276: return "Moderate or heavy rain in area with thunder"
        case ._1279: return "Patchy light snow in area with thunder"
        case ._1282: return "Moderate or heavy snow in area with thunder"
        }
    }
    
    var night: String {
        switch self {
        case ._1000: return "Clear"
        case ._1003: return "Partly Cloudy"
        case ._1006: return "Cloudy"
        case ._1009: return "Overcast"
        case ._1030: return "Mist"
        case ._1063: return "Patchy rain nearby"
        case ._1066: return "Patchy snow nearby"
        case ._1069: return "Patchy sleet nearby"
        case ._1072: return "Patchy freezing drizzle nearby"
        case ._1087: return "Thundery outbreaks in nearby"
        case ._1114: return "Blowing snow"
        case ._1117: return "Blizzard"
        case ._1135: return "Fog"
        case ._1147: return "Freezing fog"
        case ._1150: return "Patchy light drizzle"
        case ._1153: return "Light drizzle"
        case ._1168: return "Freezing drizzle"
        case ._1171: return "Heavy freezing drizzle"
        case ._1180: return "Patchy light rain"
        case ._1183: return "Light rain"
        case ._1186: return "Moderate rain at times"
        case ._1189: return "Moderate rain"
        case ._1192: return "Heavy rain at times"
        case ._1195: return "Heavy rain"
        case ._1198: return "Light freezing rain"
        case ._1201: return "Moderate or heavy freezing rain"
        case ._1204: return "Light sleet"
        case ._1207: return "Moderate or heavy sleet"
        case ._1210: return "Patchy light snow"
        case ._1213: return "Light snow"
        case ._1216: return "Patchy moderate snow"
        case ._1219: return "Moderate snow"
        case ._1222: return "Patchy heavy snow"
        case ._1225: return "Heavy snow"
        case ._1237: return "Ice pellets"
        case ._1240: return "Light rain shower"
        case ._1243: return "Moderate or heavy rain shower"
        case ._1246: return "Torrential rain shower"
        case ._1249: return "Light sleet showers"
        case ._1252: return "Moderate or heavy sleet showers"
        case ._1255: return "Light snow showers"
        case ._1258: return "Moderate or heavy snow showers"
        case ._1261: return "Light showers of ice pellets"
        case ._1264: return "Moderate or heavy showers of ice pellets"
        case ._1273: return "Patchy light rain in area with thunder"
        case ._1276: return "Moderate or heavy rain in area with thunder"
        case ._1279: return "Patchy light snow in area with thunder"
        case ._1282: return "Moderate or heavy snow in area with thunder"
        }
    }
    
    func icon(_ isDay: Int) -> UIImage? {
        switch self {
        case ._1000: return isDay == 1 ? UIImage(systemName: "sun.max.fill") : UIImage(systemName: "moon.fill")
        case ._1003: return isDay == 1 ? UIImage(systemName: "cloud.sun.fill") : UIImage(systemName: "cloud.moon.fill")
        case ._1006: return isDay == 1 ? UIImage(systemName: "cloud.fill") : UIImage(systemName: "cloud.moon.fill")
        case ._1009: return UIImage(systemName: "cloud.fill")
        case ._1063: return isDay == 1 ? UIImage(systemName: "cloud.sun.rain.fill") : UIImage(systemName: "cloud.moon.rain.fill")
        case ._1087: return isDay == 1 ? UIImage(systemName: "cloud.sun.bolt.fill") : UIImage(systemName: "cloud.moon.bolt.fill")
        case ._1117: return UIImage(systemName: "wind.snow")
        case ._1186: return isDay == 1 ? UIImage(systemName: "cloud.sun.rain.fill") : UIImage(systemName: "cloud.moon.rain.fill")
            
        case ._1030, ._1072, ._1153, ._1168, ._1171, ._1240:
            return UIImage(systemName: "cloud.drizzle.fill")
        case ._1066, ._1114, ._1210, ._1213, ._1216, ._1219, ._1222, ._1225, ._1237, ._1255, ._1258:
            return UIImage(systemName: "cloud.snow.fill")
        case ._1135, ._1147:
            return UIImage(systemName: "cloud.fog.fill")
        case ._1150, ._1180, ._1183, ._1189, ._1198:
            return UIImage(systemName: "cloud.rain.fill")
        case ._1192, ._1195, ._1201, ._1243, ._1246:
            return UIImage(systemName: "cloud.heavyrain.fill")
        case ._1069, ._1204, ._1207, ._1249, ._1252:
            return UIImage(systemName: "cloud.sleet.fill")
        case ._1261, ._1264:
            return UIImage(systemName: "cloud.hail.fill")
        case ._1273, ._1276, ._1279, ._1282:
            return UIImage(systemName: "cloud.bolt.rain.fill")
        }
    }
    
    var icon: Int {
        switch self {
        case ._1000: return 113
        case ._1003: return 116
        case ._1006: return 119
        case ._1009: return 122
        case ._1030: return 143
        case ._1063: return 176
        case ._1066: return 179
        case ._1069: return 182
        case ._1072: return 185
        case ._1087: return 200
        case ._1114: return 227
        case ._1117: return 230
        case ._1135: return 248
        case ._1147: return 260
        case ._1150: return 263
        case ._1153: return 266
        case ._1168: return 281
        case ._1171: return 284
        case ._1180: return 293
        case ._1183: return 296
        case ._1186: return 299
        case ._1189: return 302
        case ._1192: return 305
        case ._1195: return 308
        case ._1198: return 311
        case ._1201: return 314
        case ._1204: return 317
        case ._1207: return 320
        case ._1210: return 323
        case ._1213: return 326
        case ._1216: return 329
        case ._1219: return 332
        case ._1222: return 335
        case ._1225: return 338
        case ._1237: return 350
        case ._1240: return 353
        case ._1243: return 356
        case ._1246: return 359
        case ._1249: return 362
        case ._1252: return 365
        case ._1255: return 368
        case ._1258: return 371
        case ._1261: return 374
        case ._1264: return 377
        case ._1273: return 386
        case ._1276: return 389
        case ._1279: return 392
        case ._1282: return 395
        }
    }
}

