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

    private var segView: IMScrollSegmentView!
    private var contentView: IMContentView!
    private var titlesArray: [String] = []
    /// 所有的子控制器
    private var childVcs: [UIViewController] = []
    ///  当前呈现子控制器
    public var currentChildVC: UIViewController {
        return contentView.currentChildVC
    }
    /// 这里使用weak避免循环引用
    private weak var parentViewController: UIViewController?
    
    public init(frame: CGRect, segmentStyle: IMSegmentStyle, titles: [String], childVcs: [UIViewController], parnetVc: UIViewController) {
        self.parentViewController = parnetVc
        self.childVcs = childVcs
        self.titlesArray = titles
        self.segmentStyle = segmentStyle
        assert(childVcs.count == titles.count, "标题的个数必须和子控制器的个数相同")
        super.init(frame: frame)
        /// 初始化设置了frame后可以在以后的任何地方直接获取到frame了, 就不必重写layoutsubview()方法在里面设置各个控件的frame
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .white
        segView = IMScrollSegmentView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 44), titles: titlesArray, segmentStyle: segmentStyle)
        guard let parentVC = parentViewController else {
            return
        }
        segView.delegate = self
        contentView = IMContentView(frame: CGRect(x: 0, y: segmentView.frame.maxY, width: bounds.size.width, height: bounds.size.height - 44), childVCs: childVcs, parentViewController: parentVC)
        contentView.delegate = self
        addSubview(segmentView)
        addSubview(contentView)
    }
    
    deinit {
        parentViewController = nil
    }
}

extension IMScrollPageView {
    
    public func selectedIndex(selectedIndex: Int, animated: Bool) {
        segView.selectedIndex(selectedIndex, animated: animated)
    }
    
    public func reloadChildVcsWithNewTitles(_ titles: [String], newChildVcs: [UIViewController]) {
        self.childVcs = newChildVcs
        self.titlesArray = titles
        segView.reloadTitlesWithNewTitles(titles)
        contentView.reloadAllViewsWithNewChildVCs(newChildVCs: newChildVcs)
    }
}

// MARK: - IMScrollSegmentViewDelegate
extension IMScrollPageView: IMScrollSegmentViewDelegate {
    
    func scrollSegmentViewTitleButtonClick(with label: UILabel, index: Int) {
        self.contentView.setContentOffset(offset: CGPoint(x: self.contentView.bounds.size.width * CGFloat(index), y: 0),
                                          animated: self.segmentStyle.isAnimatedChangeContent)
    }
}

// MARK: - IMContentViewDelegate
extension IMScrollPageView: IMContentViewDelegate {
    public var segmentView: IMScrollSegmentView {
        return segView
    }
}
