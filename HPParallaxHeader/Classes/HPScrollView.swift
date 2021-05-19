//
//  HPScrollView.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 17/05/2021.
//

import Foundation
import UIKit

/**
 The delegate of a MXScrollView object may adopt the MXScrollViewDelegate protocol to control subview's scrolling effect.
 */
@objc protocol HPScrollViewDelegate: UIScrollViewDelegate {
    /**
     Asks the page if the scrollview should scroll with the subview.
     
     @param scrollView The scrollview. This is the object sending the message.
     @param subView    An instance of a sub view.
     
     @return YES to allow scrollview and subview to scroll together. YES by default.
     */
    func scrollViewShouldScroll(_ scrollView: HPScrollView, with subView: UIScrollView) -> Bool
}

/**
 The MXScrollView is a UIScrollView subclass with the ability to hook the vertical scroll from its subviews.
 */
class HPScrollView : UIScrollView {
    
    /**
     Delegate instance that adopt the MXScrollViewDelegate.
     */
    @IBOutlet weak var hpDelegate: HPScrollViewDelegate?
    
    @IBOutlet var parallaxHeader: HPParallaxHeader?
    
    private var observedViews: [UIScrollView] = []
    private var isObserving: Bool = true
    private var lock: Bool = false
    private var otherKvoTokens: [NSKeyValueObservation] = []
    private var myKVOToken: NSKeyValueObservation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        //            self.forwarder = [MXScrollViewDelegateForwarder new];
        //            super.delegate = self.forwarder;
        
        showsVerticalScrollIndicator = false
        isDirectionalLockEnabled = true
        bounces = true
        
        panGestureRecognizer.cancelsTouchesInView = false
        
        myKVOToken = observe(\.contentOffset, options: [.old, .new], changeHandler: {[weak self] scrollView, change in
            guard let self = self else { return }
            self.onChangeContentOffset(scrollView, change)
        })
    }

    // MARK: - Properties

//    - (void)setDelegate:(id<MXScrollViewDelegate>)delegate {
//        self.forwarder.delegate = delegate;
//        // Scroll view delegate caches whether the delegate responds to some of the delegate
//        // methods, so we need to force it to re-evaluate if the delegate responds to them
//        super.delegate = nil;
//        super.delegate = self.forwarder;
//    }
//
//    - (id<MXScrollViewDelegate>)delegate {
//        return self.forwarder.delegate;
//    }

    deinit {
        myKVOToken?.invalidate()
        removeObservedViews()
    }
}

extension HPScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer.view == self) {
            return false
        }
        
        // Ignore other gesture than pan
        if !(gestureRecognizer is UIPanGestureRecognizer) {
            return false
        }
        
        // Lock horizontal pan gesture.
        guard let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self) else {
            return false
        }
        if (fabs(velocity.x) > fabs(velocity.y)) {
            return false
        }
        
        var otherView = otherGestureRecognizer.view
        // WKWebView on he MXScrollView
        if let wkContentClass = NSClassFromString("WKContent"),
           let unwrapped = otherView, unwrapped.isKind(of: wkContentClass) {
            otherView = unwrapped.superview
        }
        
        // Consider scroll view pan only
        guard let scrollView = otherView as? UIScrollView else {
            return false
        }
        
        // Tricky case: UITableViewWrapperView
        if scrollView.superview is UITableView {
            return false
        }
        
        //tableview on the HPScrollView
        if let uiTableViewContentClass = NSClassFromString("UITableViewCellContentView"),
           (scrollView.superview?.isKind(of: uiTableViewContentClass) ?? false) {
            return false
        }
        
        let shouldScroll = (hpDelegate?.scrollViewShouldScroll(self, with: scrollView)) ?? true
        
        if shouldScroll {
            addObservedView(scrollView)
        }
        
        return shouldScroll
    }
}

// MARK: - KVO
extension HPScrollView {
    func addOserver(to scrollView: UIScrollView) -> NSKeyValueObservation {
        lock = (scrollView.contentOffset.y > -scrollView.contentInset.top)
        
        let token = scrollView.observe(\.contentOffset, options: [.old, .new]) {[weak self] scrollView, change in
            guard let self = self else { return }
            self.onChangeContentOffset(scrollView, change)
        }
        
        return token
    }
    
    //This is where the magic happens...
    func onChangeContentOffset(_ scrollView: UIScrollView, _ change: NSKeyValueObservedChange<CGPoint>) {
        let new = change.newValue ?? .zero
        let old = change.oldValue ?? .zero
        let diff = old.y - new.y
        
        if diff == 0.0 || !isObserving {
            return
        }
        
        if scrollView == self {
            
            //Adjust self scroll offset when scroll down
            if (diff > 0 && lock) {
                self.scrollView(self, setContentOffset: old)
            } else if self.contentOffset.y < -self.contentInset.top && !self.bounces {
                self.scrollView(self, setContentOffset: CGPoint(x: contentOffset.x,
                                                                y: -contentInset.top))
            } else if self.contentOffset.y > -(self.parallaxHeader?.minimumHeight ?? 0) {
                self.scrollView(self, setContentOffset: CGPoint(x: contentOffset.x,
                                                                y: -(parallaxHeader?.minimumHeight ?? 0)))
            }

        } else {
            //Adjust the observed scrollview's content offset
            lock = (scrollView.contentOffset.y > -scrollView.contentInset.top)
            
            //Manage scroll up
            if contentOffset.y < -(parallaxHeader?.minimumHeight ?? 0) && lock && (diff < 0) {
                self.scrollView(self, setContentOffset: old)
            }
            
            //Disable bouncing when scroll down
            if !lock && ((contentOffset.y > -contentInset.top) || bounces) {
                self.scrollView(scrollView, setContentOffset: CGPoint(x: scrollView.contentOffset.x,
                                                                      y: -scrollView.contentInset.top))
            }
        }
    }

}

// MARK: - Scrolling views handlers
extension HPScrollView {
    func addObservedView(_ scrollView: UIScrollView) {
        if observedViews.contains(scrollView) == false {
            observedViews.append(scrollView)
            let token = addOserver(to: scrollView)
            otherKvoTokens.append(token)
        }
    }
    
    func removeObservedViews() {
        for token in otherKvoTokens {
            token.invalidate()
        }
        otherKvoTokens.removeAll()
        observedViews.removeAll()
    }

    func scrollView(_ scrollView: UIScrollView, setContentOffset offset: CGPoint) {
        isObserving = false
        scrollView.contentOffset = offset
        isObserving = true
    }
}


//@implementation MXScrollViewDelegateForwarder
//
//- (BOOL)respondsToSelector:(SEL)selector {
//    return [self.delegate respondsToSelector:selector] || [super respondsToSelector:selector];
//}
//
//- (void)forwardInvocation:(NSInvocation *)invocation {
//    [invocation invokeWithTarget:self.delegate];
//}

// MARK: - <UIScrollViewDelegate>
extension HPScrollView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hpDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hpDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
