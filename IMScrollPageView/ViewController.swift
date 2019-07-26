//
//  ViewController.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

enum ScrollPageType {
    case scale_gradient
    case cover_gradient
    case scrollbar_gradient
    case cover_scale_no_gradient
    case cover_no_gradient_no_scroll
}

class ViewController: UIViewController {
    
    var segmentTitleView: IMScrollSegmentView!
    public var pageType: ScrollPageType = .scale_gradient
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        
        var titles = ["国内头条", "国际要闻", "趣事", "囧图", "明星八卦", "爱车", "国防要事", "科技频道", "手机专页", "风景图", "段子"]
        var style = IMSegmentStyle()
        
        switch pageType {
        case .scale_gradient:
            style.isTitleScale = true
            style.isTitleScroll = true
            style.isChangeTitleColorGradual = true
            
        case .cover_gradient:
            style.isTitleScale = true
            style.isShowCover = true
            style.isChangeTitleColorGradual = true
            style.coverBackgroundColor = UIColor.lightGray
            
        case .scrollbar_gradient:
            style.bottomLineHeight = 2
            style.isTitleScroll = true
            style.isChangeTitleColorGradual = true
            style.isShowScrollLine = true
            style.bottomLineColor = UIColor.lightGray
        case .cover_scale_no_gradient:
            style.isTitleScale = true
            style.isShowCover = true
            style.isChangeTitleColorGradual = false
            style.coverBackgroundColor = UIColor.lightGray
        case .cover_no_gradient_no_scroll:
            style.bottomLineHeight = 2
            style.isTitleScroll = true
            style.titleMargin = 20
            style.isShowScrollLine = true
            
            titles = []
        }
        
        var controllers: [UIViewController] = []
        for _ in titles.enumerated() {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.random()
            controllers.append(vc)
        }
        
        let scrollPage = IMScrollPageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
                                          segmentStyle: style, titles: titles, childVcs: controllers, parnetVc: self)
        view.addSubview(scrollPage)
        
    }
}

extension ViewController: IMContentViewDelegate {
    
    func contentViewDidEndMoveToIndex(currentIndex: Int) {
        
    }
    
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

