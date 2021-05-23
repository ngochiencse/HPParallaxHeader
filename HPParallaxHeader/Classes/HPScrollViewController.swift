//
//  MXScrollViewController.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 22/05/2021.
//

import UIKit

private var parallaxHeaderKey: UInt8 = 0

/**
 The MXScrollViewController class.
 */
public class HPScrollViewController: UIViewController {
    /**
     The scroll view container.
     */
    public let scrollView: HPScrollView = HPScrollView()
    
    /**
     The parallax header view controller to be added to the scroll view.
     */
    public var headerViewController: UIViewController? {
        didSet {
            if (oldValue?.parent == self) {
                oldValue?.willMove(toParentViewController: nil)
                oldValue?.view.removeFromSuperview()
                oldValue?.removeFromParentViewController()
                oldValue?.didMove(toParentViewController: nil)
            }

            if let headerViewController = headerViewController {
                headerViewController.willMove(toParentViewController: self)
                addChildViewController(headerViewController)

                //Set parallaxHeader view
                objc_setAssociatedObject(headerViewController, &parallaxHeaderKey,
                                         scrollView.parallaxHeader, .OBJC_ASSOCIATION_RETAIN)

                scrollView.parallaxHeader.view = headerViewController.view
                headerViewController.didMove(toParentViewController: self)
            }
        }
    }
    
    /**
     The child view controller to be added to the scroll view.
     */
    public var childViewController: UIViewController? {
        didSet {
            if oldValue?.parent == self {
                oldValue?.willMove(toParentViewController: nil)
                oldValue?.view.removeFromSuperview()
                oldValue?.removeFromParentViewController()
                oldValue?.didMove(toParentViewController: nil)
            }

            if let childViewController = childViewController {
                childViewController.willMove(toParentViewController: self)
                addChildViewController(childViewController)

                // Set UIViewController's parallaxHeader property
                objc_setAssociatedObject(childViewController, &parallaxHeaderKey,
                                         scrollView.parallaxHeader, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                scrollView.addSubview(childViewController.view)

                // Set child's constraints
                childViewController.view.translatesAutoresizingMaskIntoConstraints = false

                childViewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
                childViewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
                childViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

                childViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
                childViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

                childHeightConstraint = childViewController.view.heightAnchor
                    .constraint(equalTo: scrollView.heightAnchor, constant: -headerMinimumHeight)
                childHeightConstraint?.isActive = true

                childViewController.didMove(toParentViewController: self)
            }
        }
    }

    @IBOutlet public weak var headerView: UIView?
    @IBInspectable public var headerHeight: CGFloat {
        get {
            return scrollView.parallaxHeader.height
        }
        set {
            scrollView.parallaxHeader.height = newValue
        }
    }
    @IBInspectable public var headerMinimumHeight: CGFloat {
        get {
            return scrollView.parallaxHeader.minimumHeight
        }
        set {
            childHeightConstraint?.constant = -newValue
            scrollView.parallaxHeader.minimumHeight = newValue
        }
    }
    weak var childHeightConstraint: NSLayoutConstraint?
    
    
    private var kvoToken: NSKeyValueObservation?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        kvoToken = scrollView.parallaxHeader
            .observe(\.minimumHeight, options: .new) { [weak self] (parallaxHeader, change) in
                guard let self = self else { return }
                self.childHeightConstraint?.constant = -self.scrollView.parallaxHeader.minimumHeight;
            }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = headerHeight
        scrollView.parallaxHeader.minimumHeight = headerMinimumHeight

        //Hack to perform segues on load
        let templates: [AnyObject] = (value(forKey: "storyboardSegueTemplates") as? [AnyObject]) ?? []
        for template in templates {
            let segueClassName = template.value(forKey: "_segueClassName") as? String
            if (segueClassName?.contains(String(describing: HPScrollViewControllerSegue.self)) ?? false) ||
                (segueClassName?.contains(String(describing: HPParallaxHeaderSegue.self)) ?? false) {
                if let identifier = template.value(forKey: "identifier") as? String {
                    performSegue(withIdentifier: identifier, sender: self)
                }
            }
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            return
        }
        
        if automaticallyAdjustsScrollViewInsets {
            headerMinimumHeight = topLayoutGuide.length
        }
    }

    @available(iOS 11.0, *)
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if scrollView.contentInsetAdjustmentBehavior != .never {
            headerMinimumHeight = view.safeAreaInsets.top
            
            var safeAreaInset = UIEdgeInsets.zero
            safeAreaInset.bottom = view.safeAreaInsets.bottom
            childViewController?.additionalSafeAreaInsets = safeAreaInset
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
}

/**
 UIViewController category to let childViewControllers easily access their parallax header.
 */
public extension UIViewController {
    /**
     The parallax header.
     */
    var parallaxHeader: HPParallaxHeader? {
        if let parallaxHeader =
            objc_getAssociatedObject(self, &parallaxHeaderKey) as? HPParallaxHeader {
            return parallaxHeader
        } else if let parent = parent {
            return parent.parallaxHeader
        }
        return nil
    }

}

/**
 The MXParallaxHeaderSegue class creates a segue object to get the parallax header view controller from storyboard.
 */
public class HPParallaxHeaderSegue : UIStoryboardSegue {
    public override func perform() {
        if let svc = source as? HPScrollViewController {
            svc.headerViewController = destination
        }
    }
}

/**
 The MXScrollViewControllerSegue class creates a segue object to get the child view controller from storyboard.
 */
public class HPScrollViewControllerSegue : UIStoryboardSegue {
    public override func perform() {
        if let svc = source as? HPScrollViewController {
            svc.childViewController = destination
        }
    }
}
