//
//  KeyboardHelper.swift
//  爱肉肉
//
//  Created by isno on 16/1/13.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import UIKit

public struct KeyboardState {
    public let animationDuration: Double
    public let animationCurve: UIViewAnimationCurve
    private let userInfo: [NSObject: AnyObject]
    
    private init(_ userInfo: [NSObject: AnyObject]) {
        self.userInfo = userInfo
        
        animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        var curve = UIViewAnimationCurve.EaseIn
        if let curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int {
            NSNumber(integer: curveValue).getValue(&curve)
        }
        self.animationCurve = curve
    }
    
    // Return the height of the keyboard
    public func intersectionHeightForView(view: UIView) -> CGFloat {
        if let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            let convertedKeyboardFrame = view.convertRect(keyboardFrame, fromView: nil)
            let intersection = CGRectIntersection(convertedKeyboardFrame, view.bounds)
            return intersection.size.height
        }
        return 0
    }
    
}

public protocol KeyboardHelperDelegate: class {
    func keyboardHelper(keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState)
    func keyboardHelper(keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState)
    func keyboardHelper(keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState)
}


public class KeyboardHelper: NSObject {
    
    public static let defaultHelper = KeyboardHelper()
    
    public var currentState: KeyboardState?
    private var delegates = [WeakKeyboardDelegate]()
    
    
    public func startObserving() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardHelper.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardHelper.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardHelper.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("keyboard none")
    }
    
    public func addDelegate(delegate: KeyboardHelperDelegate) {
        for weakDelegate in delegates {
            // Reuse any existing slots that have been deallocated.
            if weakDelegate.delegate == nil {
                weakDelegate.delegate = delegate
                return
            }
        }
        
        delegates.append(WeakKeyboardDelegate(delegate))
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            currentState = KeyboardState(userInfo)
            for weakDelegate in delegates {
                weakDelegate.delegate?.keyboardHelper(self, keyboardWillShowWithState: currentState!)
            }
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            currentState = KeyboardState(userInfo)
            for weakDelegate in delegates {
                weakDelegate.delegate?.keyboardHelper(self, keyboardDidShowWithState: currentState!)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            currentState = KeyboardState(userInfo)
            for weakDelegate in delegates {
                weakDelegate.delegate?.keyboardHelper(self, keyboardWillHideWithState: currentState!)
            }
        }
    }
    
}

private class WeakKeyboardDelegate {
    weak var delegate: KeyboardHelperDelegate?
    
    init(_ delegate: KeyboardHelperDelegate) {
        self.delegate = delegate
    }
}
