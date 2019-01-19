//
//  AddThankYouViewController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2019/01/02.
//  Copyright © 2019 Aika Yamada. All rights reserved.
//

import Foundation
import UIKit

class AddThankYouViewController: UIViewController {
    
    // MARK: - Constants
    private let addThankYouTextViewHeaderViewString = "Thank You"
    private let thankYouDatePickerHeaderViewString = NSLocalizedString("Date", comment: "")
    
    // MARK: - Properties
    private var delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var addThankYouTextViewHeaderView: SettingHeaderView!
    @IBOutlet weak var addThankYouTextView: UITextView!
    @IBOutlet weak var thankYouDatePickerHeaderView: SettingHeaderView!
    @IBOutlet weak var thankYouDateView: SettingDateView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var addThankYouTextViewHeightContraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        addThankYouTextViewHeaderView.setHeaderTitle(addThankYouTextViewHeaderViewString)
        thankYouDatePickerHeaderView.setHeaderTitle(thankYouDatePickerHeaderViewString)
        addThankYouTextView.placeholder = NSLocalizedString("What are you thankful for?", comment: "")
        thankYouDateView.setDate(delegate.selectedDate ?? Date())
        
        self.navigationController?.navigationBar.barTintColor = TYLColor.navigationBarBgColor
        self.navigationController?.navigationBar.tintColor = TYLColor.navigationBarTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : TYLColor.navigationBarTextColor
        ]
        
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
    @IBAction func tappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedThankYouDateView(_ sender: UILongPressGestureRecognizer) {
        addThankYouTextView.resignFirstResponder()
        switch sender.state {
        case .began:
            thankYouDateView.changeBgColor(isHighlighted: true)
        case .ended:
            thankYouDateView.changeBgColor(isHighlighted: false)
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
extension AddThankYouViewController {
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
}


// MARK: - Extensions
extension AddThankYouViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        height = height < 80 ? 80 : height
//        let diff = height - addThankYouTextViewHeightContraint.constant
//        scrollView.contentSize.height += diff
        addThankYouTextViewHeightContraint.constant = height
//        thankYou.sizeToFit()
//        addThankYouTextView.layoutIfNeeded()
    }
}

extension AddThankYouViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        addThankYouTextView.resignFirstResponder()
    }
}
