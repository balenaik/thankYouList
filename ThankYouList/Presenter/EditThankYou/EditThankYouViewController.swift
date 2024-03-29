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

private let textViewSideMargin = CGFloat(12)
private let textViewTopBottomMargin = CGFloat(12)
private let textViewMinHeight = CGFloat(120)

private let doneButtonEnabledBgColor = UIColor.primary
private let doneButtonDisabledBgColor = UIColor.primary.withAlphaComponent(0.38)

private let rowComponentCornerRadius = CGFloat(16)

protocol EditThankYouRouter: Router {
    func dismiss()
}

class EditThankYouViewController: UIViewController {
    
    // MARK: - Properties
    var editingThankYouId: String?
    private var editingThankYou: ThankYouData?
    private var isPosting = false
    private var selectedDate = Date() {
        didSet {
            selectedDateLabel.text = selectedDate.toThankYouDateString()
        }
    }
    private var db = Firestore.firestore()
    private let analyticsManager = DefaultAnalyticsManager()
    var router: EditThankYouRouter?
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var thankYouTextView: PlaceHolderTextView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var thankYouTextViewHeightContraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupEditThankYouData()
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
    @IBAction func closeButtonDidTap(_ sender: Any) {
        guard thankYouTextView.text != editingThankYou?.value else {
            router?.dismiss()
            return
        }
        showDiscardAlert()
    }

    @IBAction func dateViewDidTap(_ sender: Any) {
        let datePickerHalfSheet = BottomHalfSheetDatePickerViewController
            .createViewController(date: selectedDate, bottomSheetDelegate: self)
        present(datePickerHalfSheet, animated: true)
    }

    @IBAction func doneButtonDidTap(_ sender: Any) {
        if isPosting || thankYouTextView.text.isEmpty {
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userId16string = String(userId.prefix(16))
        let encryptedValue = Crypto().encryptString(plainText: thankYouTextView.text,
                                                    key: userId16string)
        let thankYouData = ThankYouData(id: "",
                                        value: "",
                                        encryptedValue: encryptedValue,
                                        date: selectedDate,
                                        createTime: Date())
        editThankYou(editThankYouData: thankYouData, userId: userId)
    }
}

// MARK: - Private Methods
private extension EditThankYouViewController {
    func setupView() {
        thankYouTextView.placeHolder = R.string.localizable.edit_thank_you_text_view_placeholder()
        thankYouTextView.setInset(sideMargin: textViewSideMargin, topMargin: textViewTopBottomMargin, bottomMargin: textViewTopBottomMargin)
        thankYouTextView.becomeFirstResponder()
        thankYouTextView.layer.cornerRadius = rowComponentCornerRadius
        dateView.layer.cornerRadius = rowComponentCornerRadius
        doneButton.layer.cornerRadius = rowComponentCornerRadius

        doneButton.setBackgroundColor(
            color: doneButtonEnabledBgColor,
            for: .normal)
        doneButton.setBackgroundColor(
            color: doneButtonEnabledBgColor.darken(),
            for: .highlighted)
        doneButton.setBackgroundColor(
            color: doneButtonDisabledBgColor,
            for: .disabled)

        navigationItem.title = R.string.localizable.edit_thank_you_title()
    }

    func setupEditThankYouData() {
        guard let editingThankYou = DefaultInMemoryDataStore.shared
                .thankYouList.first(where: { $0.id == editingThankYouId }) else {
            router?.dismiss()
            return
        }
        self.editingThankYou = editingThankYou
        thankYouTextView.text = editingThankYou.value
        selectedDate = editingThankYou.date
        adjustTextViewHeight()
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
        thankYouTextView.resignFirstResponder()
    }
    
    private func editThankYou(editThankYouData: ThankYouData, userId: String) {
        guard let editingThankYouId = editingThankYouId else { return }
        isPosting = true
        db.collection(FirestoreConst.usersCollecion)
            .document(userId)
            .collection(FirestoreConst.thankYouListCollection)
            .document(editingThankYouId)
            .updateData(editThankYouData.dictionary) { [weak self] error in
                guard let self = self else { return }
                self.isPosting = false
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                    self.router?.presentAlert(message: R.string.localizable.edit_thank_you_edit_error())
                    return
                }
                self.analyticsManager.logEvent(eventName: AnalyticsEventConst.editThankYou,
                                               userId: userId,
                                               targetDate: editThankYouData.date)
                self.dismiss(animated: true, completion: nil)
            }
    }
    
    private func adjustTextViewHeight() {
        var height = thankYouTextView.sizeThatFits(
            CGSize(width: thankYouTextView.frame.size.width,
                   height: CGFloat.greatestFiniteMagnitude)).height
        height = height < textViewMinHeight ? textViewMinHeight : height
        thankYouTextViewHeightContraint.constant = height
    }

    func showDiscardAlert() {
        let discardAction = AlertAction(title: R.string.localizable.discard(),
                                        style: .destructive) { [weak self] in
            self?.router?.dismiss()
        }
        let cancelAction = AlertAction(
            title: R.string.localizable.edit_thank_you_discard_cancel(),
            style: .cancel)
        router?.presentAlert(title: R.string.localizable.edit_thank_you_discard_title(),
                             message: R.string.localizable.edit_thank_you_discard_message(),
                             actions: [discardAction, cancelAction])
    }
}


// MARK: - Extensions
extension EditThankYouViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.isEmpty
        adjustTextViewHeight()
    }
}

extension EditThankYouViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        thankYouTextView.resignFirstResponder()
    }
}

extension EditThankYouViewController: BottomHalfSheetDatePickerViewControllerDelegate {
    func bottomHalfSheetDatePickerViewControllerDidTapDone(date: Date) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        doneButton.isEnabled = !thankYouTextView.text.isEmpty
        selectedDate = date
    }
}

// MARK: - Create View Controller
extension EditThankYouViewController {
    class func createViewController(thankYouId: String) -> UIViewController? {
        guard let viewController = R.storyboard.editThankYou
                .instantiateInitialViewController() else {
            return nil
        }
        viewController.editingThankYouId = thankYouId
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
