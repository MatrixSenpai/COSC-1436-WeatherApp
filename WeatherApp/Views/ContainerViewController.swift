//
//  ContainerViewController.swift
//  WeatherApp
//
//  Created by Mason Phillips on 11/4/21.
//

import UIKit

class ContainerViewController: UIPageViewController {
    
    let api: API = .shared
    var controllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

extension ContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
    }
}
