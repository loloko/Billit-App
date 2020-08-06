//
//  AttachPopupViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 15/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class AttachPopupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionAttach: UICollectionView!
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0,left: 10.0,bottom: 10.0,right: 10.0)
    
    
    var attachList: [String] = []
    var imagePicker = UIImagePickerController()
    
    //fireebase
    var storage: Storage!
    
    //indicator
    let loading = Indicator.sharedInstance
    let singleton = Singleton.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //firebase
        storage = Storage.storage()
        
        imagePicker.delegate = self
        
        attachList =  singleton.attachList
    }
    
    @IBAction func btCloseClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (attachList.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //cell showing '+' to add more images
        if attachList.count  == indexPath.row{
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "attachAddCell", for: indexPath as IndexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attachCell", for: indexPath as IndexPath) as! AttachCollectionViewCell
        
        
        cell.ivImage.sd_setImage(with: URL(string: attachList[indexPath.row] ), completed: nil)
        
        
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        loading.showIndicator()
        
        let imageReturn = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        if let imageUpload = imageReturn.jpegData(compressionQuality: 0.4){
            
            let generalID = UUID.init().uuidString
            
            let imageref = storage.reference().child(FirebaseVars.images).child(singleton.currentUser.uid).child(FirebaseVars.cBills).child("\(generalID).jpg")
            
            imageref.putData(imageUpload, metadata: nil) { (metaData, error) in
                
                if error == nil{
                    
                    imageref.downloadURL { (url, error) in
                        if let urlImage = url?.absoluteString{
                            
                            self.attachList.append(urlImage)
                            Singleton.shared.attachList = self.attachList
                            
                            //creaye log
                            self.generateLog(isRemoved: false)
                            
                            self.collectionAttach.reloadData()
                            
                            self.loading.hideIndicator()
                        }
                        
                    }
                    
                }else{
                    self.alert(message: "Error to upload photo".localized)
                }
                
            }
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - generate log IF the bill is EDITING state
    func generateLog(isRemoved: Bool)  {
        if singleton.editBill != nil{
            singleton.logs.append(generateLogAttachImage(isBillEdit: true, isDelete: isRemoved))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //call to add images
        if attachList.count  == indexPath.row{
            //validation to user be logged in
            if !userCanEdit(){
                return
            }
            
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            
        }else{
            loading.showIndicator()
            
            //show dialog with image
            let url = URL(string: attachList[indexPath.row])
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.dialogImage(image:  UIImage(data: data!)!, url: self.attachList[indexPath.row])
                }
            }
            
        }
        
    }
    
    func dialogImage(image: UIImage, url: String)  {
        loading.hideIndicator()
        
        let alertMsg = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        alertMsg.addImage(image: image)
        alertMsg.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { action in
            
            if !self.userCanEdit(){
                return
            }
            
            self.generateLog(isRemoved: true)
            
            self.storage.reference(forURL: url).delete(completion: nil)
            self.attachList.remove(at: self.attachList.firstIndex(of: url)!)
            self.singleton.attachList = self.attachList
            
            
            self.collectionAttach.reloadData()
            
        }))
        alertMsg.addAction(UIAlertAction(title: "Close".localized, style: .default, handler: nil))
        
        
        self.present(alertMsg, animated: true, completion: nil)
    }
    
    
}


extension AttachPopupViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace - 40
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


