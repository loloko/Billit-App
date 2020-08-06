import UIKit

struct cellData {
    var opened = Bool()
    var header = Dictionary<String, Any>()
    var logs = [Dictionary<String, Any>]()
    var isAccessCode: Bool!
    
    init(_ header: Dictionary<String, Any>) {
        self.header = header
        self.opened = false
        self.isAccessCode = false
        
        //check if the bill come from a acccess code
        if self.header["is_access_code"] as! Bool{
            self.isAccessCode = true
        }
        
        
        if let activities = header[FirebaseVars.cLog] as? [Dictionary<String, Any>]{
            var date = String()
            var lastDate = String()
            
            //gather all the logs in one vareable, so its easier to search
            var logString = ""
            print(activities.count)
            for activity in activities{
                
                //make the division by date
                date = activity[FirebaseVars.date] as! String
                if date != lastDate{
                    lastDate = date
                    logs.append([FirebaseVars.date : lastDate])
                }
                
                
                let type = activity[FirebaseVars.type] as? Int
                let currency = header[FirebaseVars.currency] as! String
                
                switch type {
                //default msg (create/edit) bill
                case 1:
                    let message = activity[FirebaseVars.message] as? String
                    
                    logs.append([FirebaseVars.activity : message == "created" ? "created".localized : "edited".localized,
                                 FirebaseVars.time : activity[FirebaseVars.time]!])
                    
                    
                    logString += (activity[FirebaseVars.message] as! String)
                    
                    break
                    
                //Attach Image
                case 2:
                    let log: Dictionary<String, Any>!
                    
                    if activity[FirebaseVars.isDelete] as! Bool{
                        
                        log = [FirebaseVars.activity : "deleted 1 image".localized,
                               FirebaseVars.time : activity[FirebaseVars.time]!]
                        
                    }else{
                        let count = activity[FirebaseVars.count] as! Int
                        
                        log = [FirebaseVars.activity : "Added count image(s)".localizedArgs(count), FirebaseVars.time : activity[FirebaseVars.time]!]
                    }
                    
                    logs.append(log)
                    logString += (log[FirebaseVars.activity] as! String)
                    
                    break
                    
                // friends and how much they paid in the bill
                case 3:
                    let debtor = activity[FirebaseVars.debtorName]!
                    let amount = activity[FirebaseVars.amount] as! Double
                    
                    let log = [FirebaseVars.activity : "\(debtor) " + "paid".localized +  ":  \(currency) \(amount)",
                        FirebaseVars.time : activity[FirebaseVars.time]!]
                    
                    logs.append(log)
                    
                    logString += (log[FirebaseVars.activity] as! String)
                    
                    break
                    
                // how much who OWES/PAID who
                case 4:
                    
                    let debtor = activity[FirebaseVars.debtorName]!
                    let creditor = activity[FirebaseVars.creditorName]!
                    let amount = activity[FirebaseVars.amount] as! Double
                    let action = activity[FirebaseVars.action] as? String
                    
                    let paymentLog = [FirebaseVars.activity : "\(debtor) \(action == "owes" ? "owes".localized: "paid".localized) \(creditor): \(currency) \(amount) ",
                        FirebaseVars.time : activity[FirebaseVars.time]!]
                    
                    logs.append(paymentLog)
                    
                    logString += (paymentLog[FirebaseVars.activity] as! String)
                    
                    break
                    
                default:
                    
                    break
                    
                }
                
            }
            
            //add all information in one variable
            self.header["search"]  = logString + (header["search"] as! String)
        }
    }
}

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var bills = [cellData]()
    var billsBackup = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //style for the searchBAr
        searchBar.setStyle()
        
        //event to hide keyboard when tapped on screen
        hideKeyboardWhenTappedAround()
        
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bills.removeAll()
        
        for bill in Singleton.shared.bills{
            bills.append(cellData.init(bill.header!))
        }
        billsBackup = bills
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            bills = billsBackup
        }else{
            bills.removeAll()
            
            for item in billsBackup{
                if let search = item.header["search"] as? String{
                    if search.lowercased().contains(searchText.lowercased()){
                        bills.append(item)
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    //hide keyboard when tap SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if bills.isEmpty{
            return 1
        }
        
        return bills.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //show one cell 'Empty cell'
        if bills.isEmpty{
            return 1
        }
        
        if bills[section].opened == true{
            return bills[section].logs.count + 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //return the cell with value 'Empty'
        if bills.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityEmptyCell", for: indexPath)
            cell.separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0);
            
            return cell
        }
        
        
        let bill = bills[indexPath.section]
        
        //Header Cell
        if indexPath.row == 0{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityHeaderCell") as? BillTableViewCell else { return UITableViewCell()}
            
            cell.lbTitle.text = bill.header[FirebaseVars.title] as? String
            cell.lbDate.text =  "\(bill.header[FirebaseVars.date]!)"
            cell.lbAmount.text = "\(bill.header[FirebaseVars.currency]!) \(bill.header[FirebaseVars.amount]!)"
            
            
            if  bill.header[FirebaseVars.debts] as? [Dictionary<String, Any>] != nil{
                cell.lbAmount.textColor = UIColor(named: "colorRed")
            }else{
                cell.lbAmount.textColor = UIColor(named: "colorBlue")
            }
            
            cell.lbFriends.text = "Splitted with: names".localizedArgs(bill.header[FirebaseVars.friendString] as! String)
            
            
            //show OWNER just when the bill isnt yours
            if bill.isAccessCode{
                cell.lbOwnerName.text = "Owner: name".localizedArgs(bill.header[FirebaseVars.ownerName] as! String)
                cell.lbOwnerName.isHidden = false
            }else{
                cell.lbOwnerName.isHidden = true
            }
            
            //separator - show or hide for header
            if bill.opened == true{
                cell.separatorInset = UIEdgeInsets(top: 0, left:  cell.bounds.size.width, bottom: 0, right: 0);
            }else{
                cell.separatorInset = .zero
            }
            
            return cell
        }
        
        //Date cell
        if let date = bill.logs[indexPath.row - 1]["date"] as? String{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateActivityCell") as? BillTableViewCell else { return UITableViewCell()}
            
            cell.lbTitle.text = date
            cell.separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0);
            
            return cell
            
        }else{
            //Activities Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell") as? BillTableViewCell else { return UITableViewCell()}
            
            
            let data =  bill.logs[indexPath.row - 1]
            
            cell.lbTitle.text = data[FirebaseVars.activity] as? String
            cell.lbDate.text =  data[FirebaseVars.time] as? String
            
            //separator - show or hide for debts
            //when open the header, add a separator in the last log cell
            if indexPath.row == bill.logs.count{
                cell.separatorInset = .zero
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20);
            }
            
            
            return cell
        }
    }
    
    
    
    //MARK: - expand and close the rows
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if bills.isEmpty{
            return
        }
        
        if indexPath.row == 0{
            if bills[indexPath.section].opened == true{
                bills[indexPath.section].opened = false
            }else{
                bills[indexPath.section].opened = true
            }
            
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .fade)
        }
    }
}
