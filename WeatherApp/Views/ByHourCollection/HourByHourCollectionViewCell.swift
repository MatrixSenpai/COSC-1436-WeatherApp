//
//  HourByHourCollectionViewCell.swift
//  WeatherApp
//
//  Created by Mason Phillips on 12/2/21.
//

import UIKit

class HourByHourCollectionViewCell: UICollectionViewCell {
    typealias Item = ForecastResponse.Forecast.ForecastDay.Hour
        
    @IBOutlet weak var hourTemp: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(_ item: Item) {
        hourTemp.text = String(format: "%.2f° F", item.temp_f)
        
        let time = Date(timeIntervalSince1970: Double(item.time_epoch))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH a"
        hourLabel.text = formatter.string(from: time)
    }

}
