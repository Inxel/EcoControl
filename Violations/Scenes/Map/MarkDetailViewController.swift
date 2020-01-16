//
//  MarkDetailViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 10/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage
import RealmSwift

protocol tappedButtonDelegate {
    func userTappedButton(button: String, title: String, comment: String, url: String, amountOfPhotos: String)
}

class MarkDetailViewController: ViewControllerPannable {
    
    var delegate: tappedButtonDelegate?
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var typeOfViolationLabel: UILabel! {
        didSet {
            typeOfViolationLabel.textColor = Theme.current.textColor
        }
    }
    
    
    @IBOutlet weak var dataPicker: UIPickerView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = Theme.current.background
        }
    }
    
    var imagePicker: UIImagePickerController!
    var images = [UIImage]()
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var commentTextView: UITextView! {
        didSet {
            commentTextView.text = "Comment"
            commentTextView.layer.borderWidth = 1
            commentTextView.layer.borderColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.4330878519, alpha: 1)
            commentTextView.layer.cornerRadius = 10
            commentTextView.textColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.431372549, alpha: 1)
        }
    }
    
    @IBOutlet weak var saveButton: PrimaryButton!
    
    @IBOutlet weak var cancelButton: PrimaryButton!

    private var titleArray = ["Air pollution", "Water pollution", "Land pollution", "Deforestation", "Trash problem", "Waste", "Other"]
    private var currentTitle = ""
    private var currentComment = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        dataPicker.delegate = self
        dataPicker.dataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        view.backgroundColor = Theme.current.background
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        delegate?.userTappedButton(button: "Cancel", title: "", comment: "", url: "", amountOfPhotos: "")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        let title = currentTitle
        let comment = (commentTextView.text == "Comment" ? "" : commentTextView.text).trimmingCharacters(in: .whitespacesAndNewlines)
        let url = UUID().uuidString
        //TODO: - make array
        let amountOfPhotos = images.count
        
        saveImagesToFirebase(url)
        
        delegate?.userTappedButton(button: "Save", title: title == "" ? titleArray[0] : title, comment: comment, url: url, amountOfPhotos: String(amountOfPhotos))
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.selectImageFrom(.camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.selectImageFrom(.photoLibrary)
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - Textview Methods

extension MarkDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Comment" {
            textView.text = ""
            textView.textColor = Theme.current.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.4330878519, alpha: 1)
            textView.text = "Comment"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextView.endEditing(true)
    }
}


//MARK: - Picker view methods


extension MarkDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titleArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTitle = titleArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: titleArray[row], attributes: [NSAttributedString.Key.foregroundColor: Theme.current.textColor])
    }
}



//MARK: - Take photo methods

extension MarkDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        images.append(selectedImage)
        
        collectionView.reloadData()
    }
    
}


//MARK: - CollectionView delegate methods

extension MarkDetailViewController: UICollectionViewDelegate {
    

}


//MARK: - CollectionView data source methods

extension MarkDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.setup(with: images[indexPath.item])
        cell.delegate = self
        
        return cell
    }
    
}


//MARK: - CollectionView delegate flow layout methods

extension MarkDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = collectionView.frame.size.height - 10
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
}


//MARK: - Delete image methods

extension MarkDetailViewController: ImageCellDelegate {
    func delete(cell: ImageCollectionViewCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            images.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
        collectionView.reloadData()
    }
}


//MARK: - save photos

private extension MarkDetailViewController {
    
    func saveImagesToFirebase(_ url: String) {
        for index in 0 ..< images.count {
            PostServiceFireBase.create(for: images[index], path: "\(url)/\(index)") { downloadURL in
                guard let downloadURL = downloadURL else {
                    print("Download url not found")
                    return
                }
                print(downloadURL)
            }
        }
    }
    
}
