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
    
    @IBOutlet weak var boardCount: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backToHome(_ segue: UIStoryboardSegue) {
        
    }
    
    var dummyData: [UIImage] = [UIImage(named: "dummy1")!, UIImage(named: "dummy2")!, UIImage(named: "dummy3")!, UIImage(named: "dummy4")!, UIImage(named: "dummy5")!]
    var filteredData: [[String: Any]] = []
    var keywordsData: [[String: Any]] = []
    

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
        
        saveData()
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        
        naviFont()
        addButton.floatinBtn()
        tableView.backgroundColor = UIColor.clear
        
        let emptyImg = UIImage()
        searchBar.backgroundImage = emptyImg
        searchBar.backgroundColor = UIColor.clear

        
        token = NotificationCenter.default.addObserver(forName: EditorViewController.newListDidInsert, object: nil, queue: OperationQueue.main) {[weak self] (noti) in
            self?.tableView.reloadData()
        }
        self.searchBar.delegate = self
        self.searchBar.placeholder = "내가 저장한 단어 중에서 찾아드립니다."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        boardCount.text = "총 \(DataManager.shared.boarList.count)개의 보드"
    }
  
    //북마크 정렬
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
                
        //filteredData = keywordsData
        saveData()
        if sender.selectedSegmentIndex == 0 {
            filteredData = keywordsData
        } else if sender.selectedSegmentIndex == 1 {
            filteredData = keywordsData.filter { (item) -> Bool in
                return (item["bookmark"] as! Bool) == true
            }
            print(filteredData)
        }
        self.tableView.reloadData()
    }
    
    func saveData() {
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
            keywordsData.append(["keywords": keywordStr, "Date": formatter.string(for: item.date) ?? "", "id": item.objectID, "bookmark": item.bookmark])
        }
        filteredData = keywordsData
    }
    
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListViewTableViewCell
        /*
        let target = DataManager.shared.boarList[indexPath.row]
        cell.keywordTitle?.text = "\((target.keyword1!)), \((target.keyword2!)), \((target.keyword3!))"
        cell.dateLabel?.text = formatter.string(for: target.date)
        cell.objectId = target.objectID
        cell.configure()
        */
        let postListCell = filteredData[indexPath.row]
        cell.keywordTitle?.text = postListCell["keywords"] as? String
        cell.dateLabel.text = (postListCell["Date"] as? String) ?? ""
        cell.objectId = (postListCell["id"] as! NSManagedObjectID)
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
    
    /*
    // 테이블 뷰 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            DataManager.shared.boarList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            boardCount.text = "총\(DataManager.shared.boarList.count)개의 보드"
        }
    }
    */
    
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
        self.tableView.reloadData()
    }
    
    
}
