//
//  HPScrollViewExample.swift
//  HPParallaxHeader
//
//  Created by Hien Pham on 03/04/2021.
//  Copyright (c) 2021 Hien Pham. All rights reserved.
//

import UIKit
import HPParallaxHeader

class HPScrollViewExample: UIViewController, UITableViewDelegate, UITableViewDataSource, HPParallaxHeaderDelegate {

    fileprivate var SpanichWhite : UIColor = #colorLiteral(red: 0.9960784314, green: 0.9921568627, blue: 0.9411764706, alpha: 1) // #FEFDF0
    
    @IBOutlet weak var scrollView: HPScrollView!
    @IBOutlet weak var table1: UITableView!
    @IBOutlet weak var table2: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Parallax Header
        scrollView.parallaxHeader.load(nibName: "StarshipHeader", bundle: nil, options: [:]) // You can set the parallax header view from a nib.
        scrollView.parallaxHeader.height = 300
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.delegate = self

        table1.backgroundColor = SpanichWhite
        table1.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        table2.backgroundColor = SpanichWhite
        table2.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(format: "Row %ld", indexPath.row * 10)
        cell.backgroundColor = SpanichWhite;
        return cell
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("progress \(scrollView.parallaxHeader.progress)")
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: HPParallaxHeader) {
        print("progress \(parallaxHeader.progress)")
    }
}
