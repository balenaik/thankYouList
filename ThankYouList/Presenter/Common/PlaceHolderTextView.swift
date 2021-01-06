//
//  PlaceHolderTextView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2020/04/27.
//  Copyright © 2020 Aika Yamada. All rights reserved.
//

import UIKit

class PlaceHolderTextView: UITextView {

    private lazy var placeHolderLabel = UILabel(frame: CGRect.zero)
    var placeHolder: String = "" {
        didSet {
            placeHolderLabel.text = self.placeHolder
            placeHolderLabel.sizeToFit()
        }
    }
    private var sideMargin = CGFloat(0)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configurePlaceHolder()
        changeVisiblePlaceHolder()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeHolderLabel.preferredMaxLayoutWidth = self.frame.size.width - sideMargin * 2
    }

    override var text: String! {
        set {
            super.text = newValue
            changeVisiblePlaceHolder()
        }
        get {
            return super.text
        }
    }

    override var attributedText: NSAttributedString! {
        set {
            super.attributedText = newValue
            changeVisiblePlaceHolder()
        }
        get {
            return super.attributedText
        }
    }

    override var font: UIFont? {
        set {
            super.font = newValue
            self.placeHolderLabel.font = newValue
        }
        get {
            return super.font
        }
    }
}

// MARK: - Public Methods
extension PlaceHolderTextView {
    func setInset(sideMargin: CGFloat, topMargin: CGFloat, bottomMargin: CGFloat = 0) {
        self.sideMargin = sideMargin
        /// Set same margin on TextView and PlaceHolder
        self.textContainerInset = UIEdgeInsets(top: topMargin, left: sideMargin, bottom: bottomMargin, right: sideMargin)
        self.textContainer.lineFragmentPadding = 0
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeHolderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: sideMargin).isActive = true
        placeHolderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: sideMargin).isActive = true
        placeHolderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: topMargin).isActive = true
        placeHolderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomMargin).isActive = true
    }

    func setFontTypingAttribute(font: UIFont) {
        self.typingAttributes = [.font: font]
    }
}

// MARK: - Private Methods
extension PlaceHolderTextView {
    private func configurePlaceHolder() {
        self.placeHolderLabel.lineBreakMode = .byWordWrapping
        self.placeHolderLabel.font = self.font
        self.placeHolderLabel.textColor = UIColor.lightGray
        self.placeHolderLabel.backgroundColor = .clear
        self.placeHolderLabel.adjustsFontForContentSizeCategory = true
        self.placeHolderLabel.numberOfLines = 0
        self.addSubview(placeHolderLabel)
    }

    private func changeVisiblePlaceHolder() {
        if !self.text.isEmpty {
            self.placeHolderLabel.alpha = 0.0
        } else {
            self.placeHolderLabel.alpha = 1.0
        }
    }

    @objc private func textChanged(notification: NSNotification?) {
        changeVisiblePlaceHolder()
    }
}
