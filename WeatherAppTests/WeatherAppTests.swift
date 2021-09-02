//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Mason Phillips on 9/2/21.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class WeatherAppTests: XCTestCase {
    let api = API()
    let delegate = APIDelegate()

    override func setUpWithError() throws {
        api.delegate = delegate
    }

    override func tearDownWithError() throws {
        delegate.asyncResult = .none
        delegate.weatherExpectation = nil
        delegate.forecastExpectation = nil
        delegate.expectation = nil
    }

    func testCurrentWeatherZip() {
        delegate.expectation = expectation(description: "Get current weather")
        delegate.weatherExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }
            
            XCTAssert(response.location.localtime_epoch == Date())
            XCTAssert(response.location.region == "Texas")
            XCTAssert(response.location.name == "Austin")
            return true
        }
        
        api.currentWeatherFor(zip: "78745")
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
    func testCurrentWeatherCityState() {
        delegate.expectation = expectation(description: "Get current weather")
        delegate.weatherExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }
            
            XCTAssert(response.location.region == "Texas")
            XCTAssert(response.location.name == "Austin")
            return true
        }
        
        api.currentWeatherFor(city: "Austin", state: "TX")
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
    func testCurrentWeatherCoordinates() {
        delegate.expectation = expectation(description: "Get current weather")
        delegate.weatherExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }
            
            XCTAssert(response.location.region == "Texas")
            XCTAssert(response.location.name == "Austin")
            return true
        }
        
        let coordinates = CLLocationCoordinate2D(latitude: 30.267153, longitude: -97.743057)
        api.currentWeatherFor(location: coordinates)
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
    
    func testForecastWeatherZip() {
        delegate.expectation = expectation(description: "Get forecast")
        delegate.forecastExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }

            XCTAssert(response.location.region == "Texas")
            XCTAssert(response.location.name == "Austin")
            XCTAssert(response.forecast.forecastday.count > 0)
            XCTAssert(response.forecast.forecastday.first!.hour.count > 0)
            return true
        }
        
        api.forecastFor(zip: "78745")
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
    func testForecastWeatherCityState() {
        delegate.expectation = expectation(description: "Get forecast")
        delegate.forecastExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }

            XCTAssert(response.location.region == "Texas")
            XCTAssert(response.location.name == "Austin")
            XCTAssert(response.forecast.forecastday.count > 0)
            XCTAssert(response.forecast.forecastday.first!.hour.count > 0)
            return true
        }
        
        api.forecastFor(city: "Austin", state: "Texas")
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
    func testForecastWeatherCoordinates() {
        delegate.expectation = expectation(description: "Get forecast")
        delegate.forecastExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }

            XCTAssert(response.location.region == "Texas")
            XCTAssert(response.location.name == "Austin")
            XCTAssert(response.forecast.forecastday.count > 0)
            XCTAssert(response.forecast.forecastday.first!.hour.count > 0)
            return true
        }
        
        let coordinates = CLLocationCoordinate2D(latitude: 30.267153, longitude: -97.743057)
        api.forecastFor(location: coordinates)
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
    
    func testSearch() {
        delegate.expectation = expectation(description: "Get search results")
        delegate.searchExpectation = { (response, error) -> Bool in
            guard error == nil else { print("Error: \(error!)"); return false }
            guard let response = response else { print("Empty response"); return false }

            XCTAssert(response.count > 0)
            XCTAssert(response.first!.region == "Texas")
            XCTAssert(response.first!.name.contains("Austin"))
            return true
        }
        
        api.search(query: "Austin TX")
        wait(for: [delegate.expectation!], timeout: 5.0)
        guard let result = delegate.asyncResult, result else {
            XCTFail("Result is false"); return
        }
    }
}

class APIDelegate: WeatherResponseDelegate {
    var asyncResult: Bool? = .none
    var expectation: XCTestExpectation?
    
    var weatherExpectation : ((_ response: WeatherResponse?, _ error: Error?) -> Bool)?
    var forecastExpectation: ((_ response: ForecastResponse?, _ error: Error?) -> Bool)?
    var searchExpectation  : ((_ response: SearchResults?, _ error: Error?) -> Bool)?
    
    enum DelegateError: Error {
        case unexpectedResponseType
    }
    
    func didReturnWeather(with response: WeatherResponse) {
        // api will try to decode both types and call the respective delegate method. if we are expecting a forecast response, this should throw an error
        _ = forecastExpectation?(nil, DelegateError.unexpectedResponseType)
        _ = searchExpectation?(nil, DelegateError.unexpectedResponseType)
        let result = weatherExpectation?(response, nil)
        asyncResult = result
        expectation?.fulfill()
    }
    func didReturnForecast(with response: ForecastResponse) {
        // api will try to decode both types and call the respective delegate method. if we are expecting a weather response, this should throw an error
        _ = weatherExpectation?(nil, DelegateError.unexpectedResponseType)
        _ = searchExpectation?(nil, DelegateError.unexpectedResponseType)
        asyncResult = forecastExpectation?(response, nil)
        expectation?.fulfill()
    }
    func didReturnSearchResults(with response: SearchResults) {
        // api will try to decode both types and call the respective delegate method. if we are expecting a search response, this should throw an error
        _ = forecastExpectation?(nil, DelegateError.unexpectedResponseType)
        _ = weatherExpectation?(nil, DelegateError.unexpectedResponseType)
        asyncResult = searchExpectation?(response, nil)
        expectation?.fulfill()
    }
    
    func errorDidOccur(_ error: Error) {
        _ = weatherExpectation?(nil, error)
        _ = forecastExpectation?(nil, error)
        asyncResult = false
        expectation?.fulfill()
    }
}
