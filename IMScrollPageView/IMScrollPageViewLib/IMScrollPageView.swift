//
//  IMScrollPageView.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class IMScrollPageView: UIView {

    static let cellID: String = "cellId"
    public var segmentStyle = IMSegmentStyle()
    
    public var extraButtonOnClick: ((_ extraButton: UIButton) -> Void)? {
        didSet {
           segmentView.extraButtonClickClosure = extraButtonOnClick
        }
    }

    private var segmentView: IMScrollSegmentView!
//    private var contentView: c
}
