//
//  AppearanceViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 10.04.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class AppearanceViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var tableViewTitleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var switchButton: UISwitch!
    
    // MARK: Properties
    
    private var themeManager: ThemeManager = .shared
    private var themeModes: [ThemeMode] { ThemeMode.allCases }
    private var selectedThemeMode: ThemeMode?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeDidChange()
        setUpSwitchButton()
        setUpTableView()
        themeManager.delegate = self
    }
    
}


// MARK: - Actions

extension AppearanceViewController {
    
    @IBAction private func switchTapped(_ sender: UISwitch) {
        themeManager.changeThemeSource(useSystemTheme: sender.isOn, systemThemeIsLight: traitCollection.userInterfaceStyle == .light)
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = sender.isOn ? 0 : 1
            self.tableViewTitleLabel.alpha = sender.isOn ? 0 : 1
        }
    }
    
    @IBAction private func closeTapped(_ sender: PrimaryButton) {
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Table View Data Source

extension AppearanceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { themeModes.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as ThemeModeCell
        let themeMode = themeModes[indexPath.row]
        cell.setUp(title: themeMode.rawValue, isSelected: themeMode == selectedThemeMode, themeProtocol: themeManager.current)
        return cell
    }
    
}


// MARK: - Table View Delegate

extension AppearanceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !themeManager.useSystemTheme else { return }
        selectedThemeMode = themeModes[indexPath.row]
        themeManager.changeTheme(isLightTheme: selectedThemeMode == .light)
    }
    
}


// MARK: - Theme Manager Delegate

extension AppearanceViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        view.backgroundColor = themeManager.current.background
        titleLabel.textColor = themeManager.current.textColor
        switchLabel.textColor = themeManager.current.textColor
        tableViewTitleLabel.textColor = themeManager.current.textColor
        tableView.backgroundColor = themeManager.current.background
        selectedThemeMode = themeManager.isLightTheme ? .light : .dark
        tableView.reloadData()
    }
    
}


// MARK: - Private API

extension AppearanceViewController {
    
    private func setUpSwitchButton() {
        switchButton.isOn = themeManager.useSystemTheme
    }
    
    private func setUpTableView() {
        let isUsingSystemTheme = themeManager.useSystemTheme
        tableView.register(ThemeModeCell.self)
        selectedThemeMode = themeManager.isLightTheme ? .light : .dark
        tableView.alpha = isUsingSystemTheme ? 0 : 1
        tableViewTitleLabel.alpha = isUsingSystemTheme ? 0 : 1
    }
    
}
