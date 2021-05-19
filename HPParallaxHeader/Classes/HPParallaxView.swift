//
//  HPParallaxView.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 19/05/2021.
//

import Foundation
import UIKit

class HPParallaxView: UIView {
    weak var parent: HPParallaxHeader?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview is UIScrollView {
//            [self.superview removeObserver:self.parent forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kMXParallaxHeaderKVOContext];
        }
    }
    
    override func didMoveToSuperview() {
        if newSuperview is UIScrollView {
//            [self.superview removeObserver:self.parent forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kMXParallaxHeaderKVOContext];
        }
    }
}

@interface MXParallaxView : UIView
@property (nonatomic,weak) MXParallaxHeader *parent;
@end

@implementation MXParallaxView

static void * const kMXParallaxHeaderKVOContext = (void*)&kMXParallaxHeaderKVOContext;

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self.parent forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kMXParallaxHeaderKVOContext];
    }
}

- (void)didMoveToSuperview{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview addObserver:self.parent
                         forKeyPath:NSStringFromSelector(@selector(contentOffset))
                            options:NSKeyValueObservingOptionNew
                            context:kMXParallaxHeaderKVOContext];
    }
}

@end
