//
//  EditThankYouViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/20.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

private let textViewSideMargin = CGFloat(4)
private let textViewTopMargin = CGFloat(8)

class EditThankYouViewController: UIViewController {
    
    // MARK: - Constants
    private let addThankYouTextViewHeaderViewString = "Thank You"
    private let thankYouDatePickerHeaderViewString = NSLocalizedString("Date", comment: "")
    private let deleteViewString = NSLocalizedString("Delete", comment: "")
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate as! AppDelegate
    private var isPosting = false
    private var editingThankYouData: ThankYouData?
    private var db = Firestore.firestore()
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var addThankYouTextViewHeaderView: SettingHeaderView!
    @IBOutlet weak var editThankYouTextView: PlaceHolderTextView!
    @IBOutlet weak var thankYouDatePickerHeaderView: SettingHeaderView!
    @IBOutlet weak var thankYouDateView: SettingDateView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var deleteHeaderView: SettingHeaderView!
    @IBOutlet weak var deleteView: UIView!
    
    @IBOutlet weak var editThankYouTextViewHeightContraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        
        guard let editingThankYouData = editingThankYouData else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        editThankYouTextView.text = editingThankYouData.value
        datePicker.setDate(editingThankYouData.date, animated: true)
        thankYouDateView.setDate(editingThankYouData.date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(EditThankYouViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(EditThankYouViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
        hideKeyboard()
    }
}

// MARK: - IBActions
extension EditThankYouViewController {
    @IBAction func tappedDoneButton(_ sender: Any) {
        if isPosting || editThankYouTextView.text.isEqual("") || editThankYouTextView.text.isEmpty {
            return
        }
        guard let date = thankYouDateView.getDate(),
            let uid = Auth.auth().currentUser?.uid else { return }
        let uid16string = String(uid.prefix(16))
        let encryptedValue = Crypto().encryptString(plainText: editThankYouTextView.text, key: uid16string)
        let myThankYouData = ThankYouData(id: "", value: "", encryptedValue: encryptedValue, date: date, createTime: Date())
        editThankYou(editThankYouData: myThankYouData, uid: uid)
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedThankYouDateView(_ sender: UILongPressGestureRecognizer) {
        editThankYouTextView.resignFirstResponder()
        switch sender.state {
        case .began:
            thankYouDateView.changeBgColorOnSettingView(isHighlighted: true)
        case .ended:
            thankYouDateView.changeBgColorOnSettingView(isHighlighted: false)
            UIView.animate(withDuration: 0.3, animations: {
                self.datePickerView.alpha = !self.datePickerView.isHidden ? 0 : 1
                self.datePickerView.isHidden = !self.datePickerView.isHidden
                self.scrollView.contentOffset.y += self.datePickerView.frame.height
            })
        default:
            break
        }
    }
    
    @IBAction func tappedDeleteView(_ sender: UILongPressGestureRecognizer) {
        editThankYouTextView.resignFirstResponder()
        switch sender.state {
        case .began:
            deleteView.changeBgColorOnSettingView(isHighlighted: true)
        case .ended:
            deleteView.changeBgColorOnSettingView(isHighlighted: false)
            deleteAction()
        default:
            break
        }
    }
}

// MARK: - Internal Methods
extension EditThankYouViewController {
    @objc func datePickerValueChanged (datePicker: UIDatePicker) {
        thankYouDateView.setDate(datePicker.date)
    }
}


// MARK: - Private Methods
private extension EditThankYouViewController {
    func setupView() {
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)

        addThankYouTextViewHeaderView.setHeaderTitle(addThankYouTextViewHeaderViewString)
        thankYouDatePickerHeaderView.setHeaderTitle(thankYouDatePickerHeaderViewString)
        deleteHeaderView.hideHeaderTitle()
        editThankYouTextView.placeHolder = NSLocalizedString("What are you thankful for?", comment: "")
        editThankYouTextView.setInset(sideMargin: textViewSideMargin, topMargin: textViewTopMargin)
        adjustTextViewHeight(editThankYouTextView)
        editThankYouTextView.becomeFirstResponder()

        self.navigationItem.title = "Edit Thank You".localized
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration, animations: {
            var contentInset = self.scrollView.contentInset
            contentInset.bottom = rect.height
            self.scrollView.contentInset = contentInset
        }) { (finish) in
            self.view.setNeedsLayout()
        }
        self.view.setNeedsLayout()
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    private func hideKeyboard() {
        editThankYouTextView.resignFirstResponder()
    }
    
    private func editThankYou(editThankYouData: ThankYouData, uid: String) {
        guard let editingThankYouData = editingThankYouData else { return }
        isPosting = true
        db.collection("users").document(uid).collection("thankYouList").document(editingThankYouData.id).updateData(editThankYouData.dictionary) { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.isPosting = false
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
                let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to edit", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(alert, animated: true, completion: nil)
                return
            }
            Analytics.logEvent(eventName: AnalyticsEventConst.editThankYou, userId: uid, targetDate: editThankYouData.date)
            weakSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    private func adjustTextViewHeight(_ textView: UITextView) {
        var height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        height = height < 80 ? 80 : height
        editThankYouTextViewHeightContraint.constant = height
    }
    
    private func deleteAction() {
        let alertController = UIAlertController(title: NSLocalizedString("Delete Thank you", comment: ""),message: NSLocalizedString("Are you sure you want to delete this thank you?", comment: ""), preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertAction.Style.destructive){ (action: UIAlertAction) in
            self.deleteThankYou()
        }
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelButton)
        present(alertController,animated: true,completion: nil)
    }
    
    private func deleteThankYou() {
        guard let editingThankYouData = editingThankYouData else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Not login error")
            return
        }
        db.collection("users").document(uid).collection("thankYouList").document(editingThankYouData.id).delete(completion: { [weak self] error in
            guard let weakSelf = self else { return }
            if let error = error {
                debugPrint(error)
                let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to delete", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(alert, animated: true, completion: nil)
            }
            Analytics.logEvent(eventName: AnalyticsEventConst.deleteThankYou, userId: uid, targetDate: editingThankYouData.date)
            weakSelf.dismiss(animated: true, completion: nil)
        })
    }
}


// MARK: - Extensions
extension EditThankYouViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView)
    }
}

extension EditThankYouViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        editThankYouTextView.resignFirstResponder()
    }
}

// MARK: - Create View Controller
extension EditThankYouViewController {
    class func createViewController(thankYouData: ThankYouData?) -> EditThankYouViewController {
        let vc = UIStoryboard.init(name: "EditThankYou", bundle: nil).instantiateInitialViewController() as! EditThankYouViewController
        vc.editingThankYouData = thankYouData
        return vc
    }
}
