//
//  ViewController.swift
//  ArtGallery
//
//  Created by Esin Karan on 21.01.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
  

    @IBOutlet weak var tableView: UITableView!
    
//    Variables
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedName = ""
    var selectedId = UUID()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
       
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newDataAdded"), object: nil)
        
    }
    
    
    @objc func getData(){
                
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
       fetchRequest.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]{
                
                if let name = result.value(forKey: "name") as? String{
                    
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    
                    self.idArray.append(id)
                }
                tableView.reloadData()
                
            }
        }catch{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }

    @objc func addButtonClicked(){
        selectedName = ""
        performSegue(withIdentifier: "detailsSegue", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailsSegue"{
            
            let destination = segue.destination as? DetailsVC
            destination?.choosenId = selectedId
            destination?.choosenName = selectedName
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedName = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "detailsSegue", sender: nil)

        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
    
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let id = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id =%@",id)
            
            do{
                
                let results = try context.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject] {
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        
                        if id == idArray[indexPath.row]{
                            
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do{
                                
                                try context.save()
                                
                            }catch{
                                
                                print("error")
                            }
                        }
                    }
                }
                
            } catch{
                print("error")

            }
        }
    }
}

