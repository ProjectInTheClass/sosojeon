//
//  ListViewController.swift
//  NewMogrige
//
//  Created by 장은비 on 2020/11/16.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var boardCount: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backToHome(_ segue: UIStoryboardSegue) {
        
    }
    
    var dummyData: [UIImage] = [UIImage(named: "dummy1")!, UIImage(named: "dummy2")!, UIImage(named: "dummy3")!, UIImage(named: "dummy4")!, UIImage(named: "dummy5")!]
    var filteredData: [[String: Any]] = []
    var keywordsData: [[String: Any]] = []
    var listTarget = Board?.self

    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    var token: NSObjectProtocol?
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indextPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.board = DataManager.shared.boarList[indextPath.row]
            }
        }
    }
    
    
    @IBAction func clickAddBttn(_ sender: Any) {
        performSegue(withIdentifier: "toRandom", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.fetchBoard()
        
        if DataManager.shared.boarList.count == 0 {
            DataManager.shared.addnewBoard("고양이", "저녁노을", "흔들의자", paraMainText: "#고양이는 #저녁노을 지는 창가앞 #흔들의자에 몸을 둥글게 말고 잠들었다.", paraSubText: "전체적으로 브라운과 오렌지의 노을 빛을 배색하고 나무질감의 흔들의자와 담요를 적절히 자리를 잡아 그린다. 고양이는 실루엣으로만 표현하고 전체적으로 대비를 강하게 한다.", dummyData, false)
            
            NotificationCenter.default.post(name: EditorViewController.newListDidInsert, object: nil)
        }

        keywordsData = []
        for item in DataManager.shared.boarList {
            
            var keywordStr = ""
            if let keyword1 = item.keyword1 {
                keywordStr.append(keyword1)
                keywordStr.append(", ")
            }
            if let keyword2 = item.keyword2 {
                keywordStr.append(keyword2)
                keywordStr.append(", ")
            }
            if let keyword3 = item.keyword3 {
                keywordStr.append(keyword3)
            }
            keywordsData.append(["keywords": keywordStr, "Date": formatter.string(for: item.date) ?? "", "id": item.objectID])
        }
        filteredData = keywordsData
        
        tableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        naviFont()
        addButton.floatinBtn()
        filterButton.filterBtn()
        tableView.backgroundColor = UIColor.clear
        
        searchBar.delegate = self
        
        let emptyImg = UIImage()
        searchBar.backgroundImage = emptyImg
        searchBar.backgroundColor = UIColor.clear
        
        
//        token = NotificationCenter.default.addObserver(forName: EditorViewController.newListDidInsert, object: nil, queue: OperationQueue.main) {[weak self] (noti) in
//            self?.tableView.reloadData()
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        boardCount.text = "총 \(DataManager.shared.boarList.count)개의 보드"
    }
} // ================ viewDidLoad ================ //



extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListViewTableViewCell
        
        let postListCell = filteredData[indexPath.row]
//        let target = DataManager.shared.boarList[indexPath.row]
        //cell.keywordTitle?.text = "\(target.keyword1!), \(target.keyword2!), \(target.keyword3!)"
//        cell.dateLabel.text = formatter.string(for: postListCell.date)
        
        cell.keywordTitle?.text = postListCell["keywords"] as? String
        cell.dateLabel.text = (postListCell["Date"] as? String) ?? ""
        cell.objectId = postListCell["id"] as? NSManagedObjectID
        cell.configure()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.searchBar.resignFirstResponder()
        }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            DataManager.shared.boarList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            boardCount.text = "총\(DataManager.shared.boarList.count)개의 보드"
        }
    }
    
    //tableView 스와이프해서 삭제하기
//    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            filteredData.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//            DataManager.shared.deletBoard(listTarget)
//
//            boardCount.text = "총\(filteredData)개의 보드"
//        }
//    }
    
    //searchbar config
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = []
        
        if searchText == "" {
            filteredData = keywordsData
        } else {
            filteredData = keywordsData.filter { (item) -> Bool in
                return ((item["keywords"] as! String).lowercased().contains(searchText.lowercased()))
            }
        }
        boardCount.text = "총\(filteredData.count)개의 보드"
        self.tableView.reloadData()
    }
}
