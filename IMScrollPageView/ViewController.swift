//
//  ViewController.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var style = IMSegmentStyle()
        style.bottomLineHeight = 1
        style.isTitleScroll = true
        style.titleMargin = 20
        let segmentTitleView = IMScrollSegmentView(frame: CGRect(x: 0, y: 100, width: 375, height: 40), titles: ["首页", "电影", "话剧"], segmentStyle: style)
        view.addSubview(segmentTitleView)
    }


}

