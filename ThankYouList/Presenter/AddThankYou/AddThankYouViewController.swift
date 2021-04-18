//
//  AddThankYouViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

private let textViewSideMargin = CGFloat(4)
private let textViewTopBottomMargin = CGFloat(8)
private let textViewMinHeight = CGFloat(80)

class AddThankYouViewController: UIViewController {
    
    // MARK: - Constants
    private let addThankYouTextViewHeaderViewString = "Thank You"
    private let thankYouDatePickerHeaderViewString = NSLocalizedString("Date", comment: "")
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate as! AppDelegate
    private var isPosting = false
    private var db = Firestore.firestore()
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var addThankYouTextViewHeaderView: SettingHeaderView!
    @IBOutlet weak var addThankYouTextView: PlaceHolderTextView!
    @IBOutlet weak var thankYouDatePickerHeaderView: SettingHeaderView!
    @IBOutlet weak var thankYouDateView: SettingDateView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addThankYouTextViewHeightContraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(AddThankYouViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(AddThankYouViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
        hideKeyboard()
    }
}

// MARK: - IBActions
extension AddThankYouViewController {
    @IBAction func tappedDoneButton(_ sender: Any) {
        if isPosting || addThankYouTextView.text.isEqual("") || addThankYouTextView.text.isEmpty {
            return
        }
        guard let date = thankYouDateView.getDate(),
            let uid = Auth.auth().currentUser?.uid else { return }
        let uid16string = String(uid.prefix(16))
        let encryptedValue = Crypto().encryptString(plainText: addThankYouTextView.text, key: uid16string)
        let myThankYouData = ThankYouData(id: "", value: "", encryptedValue: encryptedValue, date: date, createTime: Date())
        addThankYou(thankYouData: myThankYouData, uid: uid)
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedThankYouDateView(_ sender: UILongPressGestureRecognizer) {
        addThankYouTextView.resignFirstResponder()
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
}

// MARK: - Internal Methods
extension AddThankYouViewController {
    @objc func datePickerValueChanged (datePicker: UIDatePicker) {
        thankYouDateView.setDate(datePicker.date)
    }
}


// MARK: - Private Methods
private extension AddThankYouViewController {
    func setupView() {
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)

        addThankYouTextViewHeaderView.setHeaderTitle(addThankYouTextViewHeaderViewString)
        thankYouDatePickerHeaderView.setHeaderTitle(thankYouDatePickerHeaderViewString)
        addThankYouTextView.placeHolder = NSLocalizedString("What are you thankful for?", comment: "")
        addThankYouTextView.setInset(sideMargin: textViewSideMargin, topMargin: textViewTopBottomMargin, bottomMargin: textViewTopBottomMargin)
        addThankYouTextView.becomeFirstResponder()
        thankYouDateView.setDate(delegate.selectedDate ?? Date())

        self.navigationItem.title = "Add Thank You".localized
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
        addThankYouTextView.resignFirstResponder()
    }
    
    private func addThankYou(thankYouData: ThankYouData, uid: String) {
        isPosting = true
        db.collection("users").document(uid).collection("thankYouList").addDocument(data: thankYouData.dictionary) { [weak self] error in
            guard let weakSelf = self else { return }
            weakSelf.isPosting = false
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
                let alert = UIAlertController(title: nil, message: NSLocalizedString("Failed to add", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(alert, animated: true, completion: nil)
                return
            }
            Analytics.logEvent(eventName: AnalyticsEventConst.addThankYou, userId: uid, targetDate: thankYouData.date)
            weakSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    func adjustTextViewHeight() {
        var height = addThankYouTextView.sizeThatFits(
            CGSize(width: addThankYouTextView.frame.size.width,
                   height: CGFloat.greatestFiniteMagnitude)).height
        height = height < textViewMinHeight ? textViewMinHeight : height
        addThankYouTextViewHeightContraint.constant = height
    }
}


// MARK: - Extensions
extension AddThankYouViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
}

extension AddThankYouViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        addThankYouTextView.resignFirstResponder()
    }
}
