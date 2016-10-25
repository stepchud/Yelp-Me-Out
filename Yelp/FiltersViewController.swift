//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Stephen Chudleigh on 10/21/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, filter: Filter)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    struct SectionItem {
        var label: String
        var param: String
        var selected: Bool
    }
    struct Section {
        var header: String?
        var expandable: Bool
        var expanded: Bool
        var items: [SectionItem]
    }

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    var filter: Filter!
    var tableLayout: [Section]!
    var switchStates: [[Int:Bool]] = [[Int:Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.filter = Filter()
        createInitialLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearch(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        var filters = [String:AnyObject]()
        var selectedCategories = [String]()
        
        let deals = tableLayout[0].items[0]
        filters["deals"] = deals.selected as AnyObject?
        
        for item in tableLayout[1].items {
            if item.selected {
                filters["distance"] = item.param as AnyObject?
            }
        }
        for item in tableLayout[2].items {
            if item.selected {
                filters["sort"] = item.param as AnyObject?
            }
        }
        
        for item in tableLayout[3].items {
            if item.selected {
                selectedCategories.append(item.param)
            }
        }
        if (selectedCategories.count > 0) {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        self.filter.updateWith(filters: filters)
        delegate?.filtersViewController?(filtersViewController: self, filter: self.filter)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tableLayout.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableLayout[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        let section = tableLayout[indexPath.section]

        let cellProps = section.items[indexPath.row]
        cell.switchLabel.text = cellProps.label
        cell.onSwitch.isOn = cellProps.selected
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let visibleHeight = tableView.estimatedRowHeight
        let section = tableLayout[indexPath.section]
        if section.expandable {
            if indexPath.section==3 {
                if section.expanded {
                    return indexPath.row == 3 ? 0 : visibleHeight
                } else {
                    return indexPath.row < 4 ? visibleHeight : 0
                }
            } else {
                if section.expanded {
                    return indexPath.row==0 ? 0 : visibleHeight
                } else {
                    return indexPath.row==0 ? visibleHeight : 0
                }
            }
        } else {
            return visibleHeight
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableLayout[section].header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section==0 {
            return 0
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        handleSelection(cell: switchCell, at: indexPath, to: value)
    }

    // default first item selected for collapsed rows
    func createInitialLayout() {
        var idx = 0
        var distanceItems = [SectionItem]()
        for option in filter.distanceOptions() {
            let item = SectionItem(label: option.label, param: option.param, selected: idx == 0)
            idx += 1
            distanceItems.append(item)
        }
        var firstItem = distanceItems[0]
        distanceItems.insert(SectionItem(label: firstItem.label, param: firstItem.param, selected: false), at: 0)
        
        idx = 0
        var sortItems = [SectionItem]()
        for option in filter.sortByOptions() {
            let item = SectionItem(label: option.label, param: option.param as String, selected: idx == 0)
            idx += 1
            sortItems.append(item)
        }
        firstItem = sortItems[0]
        sortItems.insert(SectionItem(label: firstItem.label, param: firstItem.param, selected: false), at: 0)
        
        idx = 0
        var categoryItems = [SectionItem]()
        for category in filter.defaultCategories() {
            categoryItems.append(SectionItem(label: category["name"]!, param: category["code"]!, selected: false))
            idx += 1
        }
        categoryItems.insert(SectionItem(label: "See More", param: "N/A", selected: false), at: 3)
        
        self.tableLayout = [
            Section(header: nil, expandable: false, expanded: false, items: [
                SectionItem(label: "Offering a Deal", param: "false", selected: false)
            ]),
            Section(header: "Distance", expandable: true, expanded: false, items: distanceItems),
            Section(header: "Sort By", expandable: true, expanded: false, items: sortItems),
            Section(header: "Category", expandable: true, expanded: false, items: categoryItems)
        ]
    }
    
    func handleSelection(cell: SwitchCell, at indexPath: IndexPath, to newValue: Bool) {
        if tableLayout[indexPath.section].expandable {
            if indexPath.row==0 {
                tableLayout[indexPath.section].expanded = !tableLayout[indexPath.section].expanded
            } else {
                if (indexPath.section==1 || indexPath.section==2){ // expandable values
                    tableLayout[indexPath.section].expanded = false
                    // deselect all items in section
                    for (index, _) in tableLayout[indexPath.section].items.enumerated() {
                        tableLayout[indexPath.section].items[index].selected = false
                    }
                    
                    tableLayout[indexPath.section].items[indexPath.row].selected = true
                    tableLayout[indexPath.section].items[0].label = tableLayout[indexPath.section].items[indexPath.row].label
                    tableLayout[indexPath.section].items[0].param = tableLayout[indexPath.section].items[indexPath.row].param
                    tableLayout[indexPath.section].items[0].selected = false
                } else if indexPath.section==3 { // category
                    if indexPath.row==3 && !tableLayout[indexPath.section].expanded {
                        tableLayout[indexPath.section].expanded = true
                    } else {
                        tableLayout[indexPath.section].items[indexPath.row].selected = newValue
                    }
                }
            }
            // draw updates
            tableView.reloadSections([indexPath.section], with: .fade)
        } else { // single switch, toggle it
            tableLayout[0].items[0].selected = newValue
        }

    }
}
