//
//  UITextViewPlaceholder.swift
//  TextViewPlaceholder
//
//  Original work Copyright (c) 2017 Tijme Gommers <tijme@finnwea.com>
//  Modified work Copyright (c) 2017 Yuval Tal <yuvster@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
import UIKit

extension UITextView {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.sizeToFit()
            }
        }
    }
    
    /// The UITextView placeholder text
    @IBInspectable public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(text: newValue)
            }
        }
    }
    
    @IBInspectable public var placeholderColor: UIColor {
        get {
            var placeholderColor = UIColor.lightGray
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderColor = placeholderLabel.textColor
            }
            
            return placeholderColor
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.textColor = newValue
            } else {
                self.addPlaceholder(color: newValue)
            }
        }
    }
    
    @IBInspectable public var placeholderFont: UIFont {
        get {
            var placeholderFont = font
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderFont = placeholderLabel.font
            }
            
            return placeholderFont!
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.font = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(font: newValue)
            }
        }
    }
    
    @IBInspectable public var placeholderTopInset: CGFloat {
        get {
            var inset: CGFloat = textContainerInset.top - 2
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                inset = placeholderLabel.frame.origin.y
            }
            
            return inset
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.frame.origin.y = newValue
            } else {
                self.addPlaceholder(topInset: newValue)
            }
        }
    }
    
    @IBInspectable public var placeholderLeftInset: CGFloat {
        get {
            var inset: CGFloat = textContainer.lineFragmentPadding
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                inset = placeholderLabel.frame.origin.x
            }
            
            return inset
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.frame.origin.x = newValue
            } else {
                self.addPlaceholder(leftInset: newValue)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    @objc public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(text: String? = "", font: UIFont? = nil, color: UIColor? = nil, topInset: CGFloat? = nil, leftInset: CGFloat? = nil) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = text
        placeholderLabel.font = font ?? self.font
        placeholderLabel.textColor = color ?? UIColor.lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.y = topInset ?? textContainerInset.top - 2
        placeholderLabel.frame.origin.x = leftInset ?? textContainer.lineFragmentPadding
        
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidChange),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: nil)
    }
}
