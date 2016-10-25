//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    
    //var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var currentFilter: Filter!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentFilter = Filter()
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        updateSearchResults()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusinesses != nil {
            return filteredBusinesses.count
        } else {
            print("uninitialized table data")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessTableCell", for: indexPath) as! BusinessTableCell
        cell.business = filteredBusinesses[indexPath.row]
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        print("prepare segue")
        
        let destinationController = segue.destination as! UINavigationController
        let filtersController = destinationController.topViewController as! FiltersViewController
        filtersController.delegate = self
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        if searchText.isEmpty {
            print("cleared search text")
            self.currentFilter.searchTerm = "Restaurants"
            searchBarSearchButtonClicked(searchBar)
        } else {
            self.currentFilter.searchTerm = searchText
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        if self.currentFilter.searchTerm.isEmpty {
            print("!!searching without a search term")
        } else {
            print("searching for \(self.currentFilter.searchTerm)")
        }
        
        updateSearchResults()
        perform(#selector(dismissSearchKeyboard))
    }
    
    // Update the results based on passed in filters
    func filtersViewController(filtersViewController: FiltersViewController, filter: Filter) {
        self.currentFilter = filter

        updateSearchResults()
    }
    
    func updateSearchResults() {
        Business.searchWithFilter(self.currentFilter!, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            
            }
        )
    }
    
    func dismissSearchKeyboard() {
        print("dimsiss search")
        self.searchBar.endEditing(true)
    }
}
