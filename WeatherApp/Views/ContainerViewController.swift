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
    let pageControl = UIPageControl()
    
    var defaults: UserDefaults {
        return .standard
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        self.pageControl.frame = CGRect()
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPage = 0
        self.view.addSubview(self.pageControl)
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -25).isActive = true
        self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
        self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if
            let data = defaults.object(forKey: "StoredLocations") as? Data,
            let locations = try? JSONDecoder().decode(Array<SearchCompletion>.self, from: data)
        {
            fill(locations)
            pageControl.numberOfPages = controllers.count
        } else {
            fill([])
        }
    }
    
    func fill(_ locations: Array<SearchCompletion>) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let currentLocationController = storyboard.instantiateViewController(withIdentifier: "WeatherView")
        (currentLocationController as? ViewController)?.useCurrentLocation()
        
        controllers = [currentLocationController]
        
        for location in locations {
            let controller = storyboard.instantiateViewController(withIdentifier: "WeatherView")
            (controller as? ViewController)?.receiveLocation(location)
            controllers.append(controller)
        }
        
        setViewControllers([controllers.first!], direction: .forward, animated: true, completion: nil)
    }
}

extension ContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let index = controllers.firstIndex(of: viewController),
            (index - 1) >= 0
        else { return nil }
        
        return controllers[index - 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let index = controllers.firstIndex(of: viewController),
            (index + 1) < controllers.count
        else { return nil }
        
        return controllers[index + 1]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let controller = pageViewController.viewControllers?.first,
            let index = controllers.firstIndex(of: controller)
        else { return }
        
        pageControl.currentPage = index
    }
}
