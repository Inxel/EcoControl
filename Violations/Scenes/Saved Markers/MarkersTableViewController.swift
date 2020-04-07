//
//  MarkersTableViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 23.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Protocols

protocol MarkersTableViewControllerDelegate: class {
    func didTap(on marker: Marker)
}


// MARK: - Base

final class MarkersTableViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var markersTypeIndicator: UIView!
    @IBOutlet private var markersTypeButtons: [UIButton]!
    
    @IBOutlet private weak var markersTypeViewTopConstraint: NSLayoutConstraint! {
        didSet {
            markersTypeViewTopConstraint.constant = UIApplication.shared.statusBarFrame.height
        }
    }
    @IBOutlet private weak var markersTypeIndicatorLeadingConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    private var pageContainer: UIPageViewController!
    private var pages: [UIViewController?] = []
    private var markersType: MarkersType = .saved
    private var selectedMarker: Marker? { didSet { performSegue(withIdentifier: "showMarkerInfo", sender: self) } }
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPageViewController()
        themeManager.delegate = self
        themeDidChange()
    }
    
    // MARK: Overridden API
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MarkerInfoViewController else { return }
        destinationVC.marker = selectedMarker
    }
}


// MARK: - Actions

extension MarkersTableViewController {
    
    @IBAction private func savedMarkersTapped(_ sender: UIButton) {
        changeMarkersType(to: .saved)
    }
    
    @IBAction private func addedMarkersTapped(_ sender: UIButton) {
        changeMarkersType(to: .added)
    }
    
}


// MARK: - Private API

extension MarkersTableViewController {
    
    private func changeMarkersType(to type: MarkersType) {
        switch type {
        case .saved:
            pageContainer.goToPreviousPage()
        case .added:
            pageContainer.goToNextPage()
        }
        
        markersType = type
    }
    
    private func setUpPageViewController() {
        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.dataSource = self
        pageContainer.delegate = self
        pageContainer.scrollView?.delegate = self
        
        let savedMarkersVC = SavedMarkersTableViewController.initiate(delegate: self)
        let addedMarkersVC = AddedMarkersTableViewController.initiate(delegate: self)
        
        pages.append(contentsOf: [savedMarkersVC, addedMarkersVC])
        
        if let firstVC = pages.first as? UIViewController {
            pageContainer.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageContainer.view)
        view.sendSubviewToBack(pageContainer.view)

        view.layoutIfNeeded()
    }
    
}


// MARK: - Theme Manager Delegate

extension MarkersTableViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        view.backgroundColor = themeManager.current.tableViewBackground
    }
    
}


// MARK: - MarkersTableViewController Delegate

extension MarkersTableViewController: MarkersTableViewControllerDelegate {
    
    func didTap(on marker: Marker) {
        selectedMarker = marker
    }
    
}


// MARK: - Page View Controller Data Source

extension MarkersTableViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex != 0 else { return nil }
        let previousIndex = currentIndex - 1
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        
        guard currentIndex < pages.count - 1 else { return nil }
        
        return pages[nextIndex]
    }
    
}


extension MarkersTableViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard
                let viewController = pageViewController.viewControllers?.first,
                let index = pages.firstIndex(of: viewController)
            else { return }
            
            markersType = MarkersType(rawValue: index) ?? .saved
        }
        
    }
}


// MARK: - Scroll View Delegate

extension MarkersTableViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if markersType.rawValue == 0 && scrollView.contentOffset.x < scrollView.bounds.width {
            markersTypeIndicatorLeadingConstraint.constant = 0
            return
        } else if markersType.rawValue == 1 && scrollView.contentOffset.x > scrollView.bounds.width {
            markersTypeIndicatorLeadingConstraint.constant = scrollView.bounds.width / 2
            return
        }
        
        let markersTypeIndicatorOffset = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / 2
        
        guard markersTypeIndicatorOffset != 0 else { return }

        markersTypeIndicatorLeadingConstraint.constant = markersTypeIndicatorOffset
        view.layoutIfNeeded()
    }
    
}


// MARL: - Markers Type

extension MarkersTableViewController {
    
    private enum MarkersType: Int, CaseIterable {
        case saved = 0
        case added = 1
    }
    
}
