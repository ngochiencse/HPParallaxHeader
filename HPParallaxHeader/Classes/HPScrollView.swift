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
    
    private var observedViews: [UIScrollView] = []
    private var isObserving: Bool = true
    private var lock: Bool = false
    
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
        
        addObserver(self, forKeyPath: "contentOffset",
                    options: [.new, .old], context: nil)
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
        
        let shouldScroll = (hpDelegate?.scrollViewShouldScroll(self, with: scrollView)) ?? tru
        
        if shouldScroll {
//            [self addObservedView:scrollView];
        }
        
        return shouldScroll
    }
}

#pragma mark <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (otherGestureRecognizer.view == self) {
        return NO;
    }
    
    // Ignore other gesture than pan
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    // Lock horizontal pan gesture.
    CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self];
    if (fabs(velocity.x) > fabs(velocity.y)) {
        return NO;
    }
    
    UIView *otherView = otherGestureRecognizer.view;
    // WKWebView on he MXScrollView
    if ([otherView isKindOfClass:NSClassFromString(@"WKContentView")]) {
        otherView = otherView.superview;
    }
    // Consider scroll view pan only
    if (![otherView isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    
    UIScrollView *scrollView = (id)otherView;
    
    // Tricky case: UITableViewWrapperView
    if ([scrollView.superview isKindOfClass:[UITableView class]]) {
        return NO;
    }
    //tableview on the MXScrollView
    if ([scrollView.superview isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
        return NO;
    }
    
    BOOL shouldScroll = YES;
    if ([self.delegate respondsToSelector:@selector(scrollView:shouldScrollWithSubView:)]) {
        shouldScroll = [self.delegate scrollView:self shouldScrollWithSubView:scrollView];;
    }
    
    if (shouldScroll) {
        [self addObservedView:scrollView];
    }
    
    return shouldScroll;
}

#pragma mark KVO

- (void)addObserverToView:(UIScrollView *)scrollView {
    _lock = (scrollView.contentOffset.y > -scrollView.contentInset.top);
    
    [scrollView addObserver:self
                 forKeyPath:NSStringFromSelector(@selector(contentOffset))
                    options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                    context:kMXScrollViewKVOContext];
}

- (void)removeObserverFromView:(UIScrollView *)scrollView {
    @try {
        [scrollView removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(contentOffset))
                           context:kMXScrollViewKVOContext];
    }
    @catch (NSException *exception) {}
}

//This is where the magic happens...
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kMXScrollViewKVOContext && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        
        CGPoint new = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint old = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        CGFloat diff = old.y - new.y;
        
        if (diff == 0.0 || !_isObserving) return;
        
        if (object == self) {
            
            //Adjust self scroll offset when scroll down
            if (diff > 0 && _lock) {
                [self scrollView:self setContentOffset:old];
                
            } else if (self.contentOffset.y < -self.contentInset.top && !self.bounces) {
                [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.contentInset.top)];
            } else if (self.contentOffset.y > -self.parallaxHeader.minimumHeight) {
                [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.parallaxHeader.minimumHeight)];
            }
            
        } else {
            //Adjust the observed scrollview's content offset
            UIScrollView *scrollView = object;
            _lock = (scrollView.contentOffset.y > -scrollView.contentInset.top);
            
            //Manage scroll up
            if (self.contentOffset.y < -self.parallaxHeader.minimumHeight && _lock && diff < 0) {
                [self scrollView:scrollView setContentOffset:old];
            }
            //Disable bouncing when scroll down
            if (!_lock && ((self.contentOffset.y > -self.contentInset.top) || self.bounces)) {
                [self scrollView:scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top)];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Scrolling views handlers

- (void)addObservedView:(UIScrollView *)scrollView {
    if (![self.observedViews containsObject:scrollView]) {
        [self.observedViews addObject:scrollView];
        [self addObserverToView:scrollView];
    }
}

- (void)removeObservedViews {
    for (UIScrollView *scrollView in self.observedViews) {
        [self removeObserverFromView:scrollView];
    }
    [self.observedViews removeAllObjects];
}

- (void)scrollView:(UIScrollView *)scrollView setContentOffset:(CGPoint)offset {
    _isObserving = NO;
    scrollView.contentOffset = offset;
    _isObserving = YES;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kMXScrollViewKVOContext];
    [self removeObservedViews];
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lock = NO;
    [self removeObservedViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        _lock = NO;
        [self removeObservedViews];
    }
}

@end

@implementation MXScrollViewDelegateForwarder

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.delegate respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.delegate];
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [(MXScrollView *)scrollView scrollViewDidEndDecelerating:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(MXScrollView *)scrollView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

@end
