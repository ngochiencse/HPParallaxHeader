//
//  ParchmentExampleViewController.swift
//  HPParallaxHeader_Example
//
//  Created by Hien Pham on 29/05/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Parchment
import HPParallaxHeader

class ParchmentExampleViewController: UIViewController {

    @IBOutlet weak var pagingContainer: UIView!
    @IBOutlet weak var scrollView: HPScrollView!
    var viewControllers: [TableViewController] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView.parallaxHeader.load(nibName: "StarshipHeader", bundle: nil, options: [:]) // You can set the parallax header view from a nib.
        scrollView.parallaxHeader.height = 300
        scrollView.parallaxHeader.mode = .fill

        viewControllers = [
            TableViewController(count: 500),
            TableViewController(count: 1),
            TableViewController(count: 10),
            TableViewController(count: 20),
        ]
        for index in 0..<viewControllers.count {
            viewControllers[index].title = String(index)
        }

        let pagingViewController = PagingViewController(viewControllers: viewControllers)

        // Make sure you add the PagingViewController as a child view
        // controller and constrain it to the edges of the view.
        addChild(pagingViewController)
        pagingContainer.addSubview(pagingViewController.view)
        pagingContainer.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.parallaxHeader.minimumHeight = view.safeAreaInsets.top
        viewControllers.forEach { viewController in
            viewController.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                       bottom: scrollView.parallaxHeader.minimumHeight,
                                                       right: 0)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
