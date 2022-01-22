//
//  DetailsVC.swift
//  ArtGallery
//
//  Created by Esin Karan on 21.01.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
//    Variables
    var choosenName = ""
    var choosenId = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenName != "" {
            saveButton.isHidden = true
            
//     AppDelegate settings
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
//     Fetch operations
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = choosenId.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context?.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject]{
                    
                    if let name = result.value(forKey: "name") as? String{
                        
                        nameTextField.text = name
                    }
                    if let artist = result.value(forKey: "artist") as? String{
                        
                        artistTextField.text = artist
                    }
                    if let year = result.value(forKey: "year") as? Int{
                        
                        yearTextField.text = String(year)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data{
                        
                        let image = UIImage(data: imageData)
                        artImageView.image = image
                    }
                }
                
                
            }catch{
                
                print(error.self)
                
            }
        }
        
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            yearTextField.text = ""
            artistTextField.text = ""
            
            
        }
        
        artImageView.isUserInteractionEnabled = true
        
//        Recognizers
        let imageGestureRegonizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        artImageView.addGestureRecognizer(imageGestureRegonizer)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    @objc func selectImage(){
        
// image selection is done here
    
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        artImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        saveButton.isEnabled = true
    }
   
    @IBAction func SaveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
//        Attiributes
    
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        
        if let year = Int(yearTextField.text!){
                 
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = artImageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
            
        }catch{
            print("error")
            
        }

        NotificationCenter.default.post(name: NSNotification.Name("newDataAdded"), object: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func hideKeyboard(){
        
        view.endEditing(true)
    }
    
}

