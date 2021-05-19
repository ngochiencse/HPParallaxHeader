//
//  HPParallaxHeader.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 06/03/2021.
//

import Foundation
import UIKit

public enum MXParallaxHeaderMode {
    /**
     The option to scale the content to fill the size of the header. Some portion of the content may be clipped to fill the header’s bounds.
     */
    case fill
    /**
     The option to scale the content to fill the size of the header and aligned at the top in the header's bounds.
     */
    case topFill
    /**
     The option to center the content aligned at the top in the header's bounds.
     */
    case top
    /**
     The option to center the content in the header’s bounds, keeping the proportions the same.
     */
    case center
    /**
     The option to center the content aligned at the bottom in the header’s bounds.
     */
    case bottom
}

public protocol HPParallaxHeaderDelegate: AnyObject {
    /**
     Tells the header view that the parallax header did scroll.
     The view typically implements this method to obtain the change in progress from parallaxHeaderView.

     @param parallaxHeader The parallax header that scrolls.
     */
    func parallaxHeaderDidScroll(_ parallaxHeader: HPParallaxHeader)
}

public class HPParallaxHeader: NSObject {
    /**
     The content view on top of the UIScrollView's content.
     */
    public let contentView: UIView
    
    /**
     Delegate instance that adopt the MXScrollViewDelegate.
     */
    public weak var delegate: HPParallaxHeaderDelegate?
    
    /**
     The header's view.
     */
    @IBOutlet public var view: UIView?
    
    /**
     The header's default height. 0 by default.
     */
    @IBInspectable public var height: CGFloat = 0

    /**
     The header's minimum height while scrolling up. 0 by default.
     */
    @IBInspectable public var minimumHeight: CGFloat = 0
    
    /**
     The parallax header progress value.
     */
    public private(set) var progress: CGFloat = 0
    
    /**
     Loads a `view` from the nib file in the specified bundle.

     @param name The name of the nib file, without any leading path information.
     @param bundleOrNil The bundle in which to search for the nib file. If you specify nil, this method looks for the nib file in the main bundle.
     @param optionsOrNil A dictionary containing the options to use when opening the nib file. For a list of available keys for this dictionary, see NSBundle UIKit Additions.
     */
    public func load(nibName name: String, bundle bundleOrNil: Bundle?, options: [UINib.OptionsKey: Any]) {
        
    }
}

