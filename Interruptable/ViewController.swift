//
//  ViewController.swift
//  Interruptable
//
//  Created by Janum Trivedi on 7/20/20.
//  Copyright © 2020 Janum Trivedi. All rights reserved.
//

import UIKit

class ViewController: TableViewController {

    var menuContainer = MenuContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButtonItems()
        
        add(child: menuContainer)
    }
    
    func addBarButtonItems() {
        let presentMenuBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentMenu(sender:)))
        presentMenuBarButtonItem.tintColor = .systemBlue
        self.navigationItem.rightBarButtonItem = presentMenuBarButtonItem
    }
    
    @objc func presentMenu(sender: UIBarButtonItem) {
        menuContainer.toggle()
    }
    
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        if let cell = cell {
            cell.textLabel?.text = "Row \(indexPath.row)"
        }
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
