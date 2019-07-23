//
//  ViewController.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var segmentTitleView: IMScrollSegmentView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titles = ["首页", "电影", "话剧", "三个字", "hello world"]
        var style = IMSegmentStyle()
        style.bottomLineHeight = 2
        style.isTitleScroll = true
        style.titleMargin = 20
        style.isShowScrollLine = true
        
        var controllers: [UIViewController] = []
        for _ in titles.enumerated() {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.random()
            controllers.append(vc)
        }
        
        let scrollPage = IMScrollPageView(frame: CGRect(x: 0, y: 100, width: 375, height: 667-150), segmentStyle: style, titles: titles, childVcs: controllers, parnetVc: self)
        view.addSubview(scrollPage)
        
//        segmentTitleView = IMScrollSegmentView(frame: CGRect(x: 0, y: 100, width: 375, height: 40), titles: titles, segmentStyle: style)
//        view.addSubview(segmentTitleView)
//
//        let contentView = IMContentView(frame: CGRect(x: 0, y: 150, width: 375, height: 400), childVCs: controllers, parentViewController: self)
//        contentView.delegate = self
//        view.addSubview(contentView)
        
    }
}

extension ViewController: IMContentViewDelegate {
    
    var segmentView: IMScrollSegmentView {
        return segmentTitleView
    }
    
    func contentViewMoveToIndex(fromIndex: Int, toIndex: Int, progress: CGFloat) {
//        segmentTitleView.selectedIndex(toIndex, animated: true)
    }
}

extension CGFloat {
    /// SwiftRandom extension
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

public extension UIColor {
    /// SwiftRandom extension
    static func random(_ randomAlpha: Bool = false) -> UIColor {
        let randomRed   = CGFloat.random()
        let randomGreen = CGFloat.random()
        let randomBlue  = CGFloat.random()
        let alpha       = randomAlpha ? CGFloat.random() : 1.0
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
    }
}

