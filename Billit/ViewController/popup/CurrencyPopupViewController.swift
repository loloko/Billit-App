//
//  CurrencyPopupViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 22/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

struct ResponseData: Decodable {
    var currencies: [Currency]
}
struct Currency: Decodable {
    
    let country: String
    let currency: String
    let code: String
    let currency_number: String
    let decimal_digits: String
}

import UIKit

class CurrencyPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
        
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewCurrency: UITableView!
    
    var currencies: [Currency]!
    var currenciesBackup: [Currency]!
    
    var currencySelected: Currency!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.setStyle()

        if let path = Bundle.main.url(forResource: "currency", withExtension: "json") {
            do {
                
                let data = try Data(contentsOf: path)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ResponseData.self, from: data)
                currencies = jsonData.currencies
                currenciesBackup = jsonData.currencies
            } catch {
                print("error:\(error)")
            }
            
        }

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            currencies = currenciesBackup
        }else{
            let currencyFilter = currenciesBackup
            currencies.removeAll()
            
            for item in currencyFilter!{
                if item.country.lowercased().contains(searchText.lowercased()) ||
                    item.code.lowercased().contains(searchText.lowercased()) ||
                    item.currency.lowercased().contains(searchText.lowercased())   {
                    currencies.append(item)
                }
                
            }
            
        }
        tableViewCurrency.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currencies.isEmpty{
            return 1
        }
        
        return currencies.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if currencies.isEmpty{
            return tableView.dequeueReusableCell(withIdentifier: "currencyNotFoundCell", for: indexPath)
        }
        
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyTableViewCell
        
        let currency =  currencies[indexPath.row]
        
        cell.lbCountry.text = currency.country
        cell.lbCurrency.text = "\(currency.code) - \(currency.currency)"
        cell.contentView.backgroundColor = .clear
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if currencies.isEmpty{
            return
        }
        
        //set blue color for selected row
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "colorBlue")
       
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectedBackgroundView = backgroundView
       
        
        self.view.endEditing(true)
        
        currencySelected = currencies[indexPath.row]
    }
    
    @IBAction func btSelectClick(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "currencyPopup"), object: currencySelected)
        
        dismiss(animated: true)
    }
    
    @IBAction func btCancelClick(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
