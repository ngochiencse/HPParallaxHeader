//
//  UIScrollView+ParallaxHeader.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 22/05/2021.
//

import Foundation
import UIKit

private var parallaxHeaderKey: UInt8 = 0
public extension UIScrollView {
    @IBOutlet var parallaxHeader: HPParallaxHeader! { // cat is *effectively* a stored property
        get {
            return associatedObject(base: self, key: &parallaxHeaderKey)
                {
                let parallaxHeader = HPParallaxHeader()
                parallaxHeader.scrollView = self
                return parallaxHeader
            } // Set the initial value of the var
        }
        set { associateObject(base: self, key: &parallaxHeaderKey, value: newValue) }
    }
}
