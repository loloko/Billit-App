//
//  ReportTableViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 17/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

struct cellReport {
    var opened = Bool()
    var header: DebitPersonModel!
    var data: [DebitPersonModel] = []
    
    init(_ header: DebitPersonModel ) {
        self.header = header
        self.opened = true
        self.data.append(header)
    }
}

class ReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var reportList: [cellReport] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createReport()
        
         tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if reportList.isEmpty{
            return 1
        }
        
        return reportList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //show one cell 'Empty cell'
        if reportList.isEmpty{
            return 1
        }
        
        if reportList[section].opened == true{
            return reportList[section].data.count + 1
        }else{
            return 1
        }
    }
    
    
    //MARK: - POPULATE TABLE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return the cell with value 'Empty'
        if reportList.isEmpty{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "reportCellEmpty", for: indexPath)
            
             cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            
            return cell
        }
        
        
        let report = reportList[indexPath.section]
        
        if indexPath.row == 0{
            //Header
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reportHeaderCell")  as? DebtTableViewCell else { return UITableViewCell()}
            
            cell.lbDebitorName.text = report.header.debtorName
            cell.lbAmount.text = "Total: \(report.header.amount ?? 0)"
            
            //separator - show or hide for header
            if report.opened{
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            }else{
                cell.separatorInset = .zero
            }
            
            return cell
            
        }
        
        //Activities
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell") as? DebtTableViewCell else { return UITableViewCell()}
        
        let data = report.data[indexPath.row - 1]
        
        cell.lbDebitorName.text = "\(data.debtorName!) " + "owes".localized + " \( data.creditorName!) "
        cell.lbAmount.text = "\(data.amount!)  \(data.currency!)"
        
        //separator - show or hide for debts
        //when open the header, add a separator in the last log cell
        if indexPath.row == report.data.count{
            cell.separatorInset = .zero
        }else{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20);
        }
        
        
        return cell
        
    }
//    MARK: - SELECT ITEM
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reportList.isEmpty{
            return
        }
        //exapand and close the header
        if indexPath.row == 0{
            if reportList[indexPath.section].opened{
                reportList[indexPath.section].opened = false
            }else{
                reportList[indexPath.section].opened = true
            }
            
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }
    }
    
    func createReport()  {
        
        for bill in Singleton.shared.bills{
            
            for debt in bill.debts{
                
                var exist = false
                var index = 0
                for var report in reportList{
                    //check if alreaady have a header
                    if report.header.debtorId == debt.debtorId{
                        exist = true
                        report.header.amount += debt.amount
                        
                        
                        //sum the same credite person
                        var existDebt = false
                        var indexDebt = 0
                        for var dt in report.data{
                            
                            
                            //check if its same CREDITOR and same CURRENCY
                            if dt.creditorId == debt.creditorId && dt.currency == debt.currency{
                                
                                existDebt = true
                                dt.amount += debt.amount
                                report.data[indexDebt] = dt
                            }
                            
                            indexDebt += 1
                        }
                        
                        if !existDebt {
                            report.data.append(debt)
                        }
                        
                        
                        reportList[index] = report
                    }
                    index += 1
                }
                if !exist{
                    reportList.append(cellReport.init(debt))
                }
                
            }
            
        }
        
    }
    
}
