//
//  CreatingMarkerViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 10/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage
import RealmSwift


// MARK: - Protocols

protocol TappedButtonDelegate: class {
    func userTappedButton(button: CreatingMarkerViewController.ButtonType, title: String?, comment: String?, url: String?, amountOfPhotos: String?)
}


extension TappedButtonDelegate {
    func userTappedButton(button: CreatingMarkerViewController.ButtonType, title: String? = nil, comment: String? = nil, url: String? = nil, amountOfPhotos: String? = nil) {}
}


// MARK: - Base

final class CreatingMarkerViewController: CollectionViewItemsReorderingVC<UIImage> {
    
    weak var delegate: TappedButtonDelegate?
    
    // MARK: Oultets
    
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet private weak var typeOfViolationLabel: UILabel!
    @IBOutlet private weak var dataPicker: UIPickerView!
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseID)
            collectionView.dragInteractionEnabled = true
        }
    }
    
    @IBOutlet private weak var addPhotoView: UIView!
    @IBOutlet private weak var addPhotoViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var commentTextView: UITextView! {
        didSet {
            commentTextView.text = "Comment"
            commentTextView.layer.borderWidth = 1
            commentTextView.layer.borderColor = UIColor.primary.cgColor
            commentTextView.layer.cornerRadius = 10
            commentTextView.textColor = .primary
        }
    }
    
    @IBOutlet private weak var saveButton: PrimaryButton!
    @IBOutlet private weak var cancelButton: PrimaryButton!
    
    // MARK: Properties
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()

    private var reports: [ReportsType] { ReportsType.allCases }
    private var currentTitle: String = ""
    private var currentComment: String = ""
    
    private var imagePicker: UIImagePickerController!
//    var items: [UIImage] = []
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        themeDidChange()
        addObservers()
    }
    
    deinit { removeObservers() }
    
    // MARK: Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseID, for: indexPath) as! ImageCollectionViewCell
        
        cell.setup(with: items[indexPath.item])
        cell.delegate = self
        
        return cell
    }
    
}


// MARK: - Actions

extension CreatingMarkerViewController: ProgressHUDShowing {
    
    @IBAction private func cancelTapped(_ sender: PrimaryButton) {
        delegate?.userTappedButton(button: .cancel)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func saveTapped(_ sender: PrimaryButton) {
        guard CheckInternet.connection() else {
            showProgressHUDError(with: "Check your internet connection")
            return
        }
        
        let title = currentTitle
        let comment = (commentTextView.text == "Comment" ? "" : commentTextView.text).trimmingCharacters(in: .whitespacesAndNewlines)
        let url = UUID().uuidString
        let amountOfPhotos = items.count
        
        saveImagesToFirebase(url)
        
        delegate?.userTappedButton(button: .save, title: title.isEmpty ? reports.first?.rawValue : title, comment: comment, url: url, amountOfPhotos: String(amountOfPhotos))
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func addPhoto(_ sender: UIButton) {
        
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


// MARK: - Theme Manager Delegate

extension CreatingMarkerViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        typeOfViolationLabel.textColor = themeManager.current.textColor
        collectionView.backgroundColor = themeManager.current.background
        view.backgroundColor = themeManager.current.background
        commentTextView.textColor = commentTextView.text == "Comment" ? .primary : themeManager.current.textColor
        dataPicker.reloadInputViews()
    }
    
}


// MARK: - Text View Delegate

extension CreatingMarkerViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Comment" {
            textView.text = ""
            textView.textColor = themeManager.current.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = .primary
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
    
}


//MARK: - Picker View Methods

extension CreatingMarkerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { reports.count }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { reports[row].rawValue }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTitle = reports[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: reports[row].rawValue, attributes: [NSAttributedString.Key.foregroundColor: themeManager.current.textColor])
    }
}



//MARK: - Take photo methods

extension CreatingMarkerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func selectImageFrom(_ source: ImageSource) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        items.append(selectedImage)
        
        collectionView.reloadData()
    }
    
}


// MARK: - Scroll View Delegate

extension CreatingMarkerViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }

        addPhotoViewLeadingConstraint.constant = -scrollView.contentOffset.x
        view.layoutIfNeeded()
    }
    
}


//MARK: - Collection View Delegate Flow Layout

extension CreatingMarkerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellSize = collectionView.frame.size.height - 10
        
        return .init(width: cellSize, height: cellSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(top: 0, left: addPhotoView.frame.width, bottom: 0, right: 20)
    }
    
}

//
//// MARK: - Collection View Drag And Drop
//
//extension CreatingMarkerViewController: CollectionViewItemsReordering, CollectionViewDragAndDropDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        dragDidBegin(collectionView, itemsForBeginning: session, at: indexPath)
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        dropSessionDidUpdate session: UIDropSession,
//        withDestinationIndexPath destinationIndexPath: IndexPath?
//    ) -> UICollectionViewDropProposal {
//        itemPositionDidChange(collectionView, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        integrateDroppedItem(collectionView, performDropWith: coordinator)
//    }
//
//}


//MARK: - Image Cell Delegate

extension CreatingMarkerViewController: ImageCellDelegate {
    
    func delete(cell: ImageCollectionViewCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            items.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
        collectionView.reloadData()
    }
    
}


//MARK: - Private API

extension CreatingMarkerViewController {
    
    private func saveImagesToFirebase(_ url: String) {
        for index in 0 ..< items.count {
            PostServiceFireBase.create(for: items[index], path: "\(url)/\(index)") { downloadURL in
                guard let downloadURL = downloadURL else {
                    print("Download url not found")
                    return
                }
                print(downloadURL)
            }
        }
    }
    
}


// MARK: - Keyboard Showing

extension CreatingMarkerViewController: KeyboardShowing {}


// MARK: - Mark Detail Screen Button Type

extension CreatingMarkerViewController {
    
    enum ButtonType {
        case save
        case cancel
    }

}
