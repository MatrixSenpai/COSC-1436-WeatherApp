//
//  SearchTableViewController.swift
//  SearchTableViewController
//
//  Created by Mason Phillips on 10/21/21.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    let api: API = .shared
    var searchResults: Array<SearchCompletion> = []
    
    var selectedResult: SearchCompletion?
    
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        api.delegate = self
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        
        var currentSavedLocations: Array<SearchCompletion>
        if
            let defaultsData = UserDefaults.standard.data(forKey: "StoredLocations"),
            let decodedData = try? JSONDecoder().decode(Array<SearchCompletion>.self, from: defaultsData)
        {
            currentSavedLocations = decodedData
        } else {
            currentSavedLocations = []
        }
        
        currentSavedLocations.append(selectedResult)
        
        if let newData = try? JSONEncoder().encode(currentSavedLocations) {
            UserDefaults.standard.set(newData, forKey: "StoredLocations")
        }
        
        navigationController?.popViewController(animated: true)
        
//        api.forecastFor(location: selectedResult.coordinates)
//
//        if let storedData = try? JSONEncoder().encode(selectedResult) {
//            UserDefaults.standard.set(storedData, forKey: "DefaultLocation")
//        }
    }
}

extension SearchTableViewController: WeatherResponseDelegate {
    func didReturnWeather(with response: WeatherResponse) {}
    func didReturnForecast(with response: ForecastResponse) {}
    
    func didReturnSearchResults(with response: SearchResults) {
        searchResults = response
        tableView.reloadData()
    }
    
    func errorDidOccur(_ error: Error) {
        print(error)
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 3 {
            api.search(query: searchText)
        } else if searchText.isEmpty {
            searchResults = []
            tableView.reloadData()
        }
    }
}
