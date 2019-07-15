//
//  IMContentView.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

class IMContentView: UIView {

    static let cellID = "cellid"
    /// 所有的子控制器
    private var childVCs: [UIViewController] = []
    /// 用来判断是否是点击了title, 点击了就不要调用scrollview的代理来进行相关的计算
    private var forbidTouchToAdjustPosition = false
    /// 用来记录开始滚动的offSetX
    private var oldOffsetX: CGFloat = 0.0
    private var oldIndex: Int = 0
    public private(set) var currentIndex: Int = 0
    /// 当前显示的子控制器
    public var currentChildVC: UIViewController {
        return childVCs[currentIndex]
    }
    
    private weak var parentViewController: UIViewController?
    public weak var delegate: IMContentViewDelegate?
    
    private lazy var  collectionView: UICollectionView = { [weak self] in
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.scrollsToTop = false
        if let strongSelf = self {
            flowLayout.itemSize = strongSelf.bounds.size
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            
            collectionView.bounces = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.frame = strongSelf.bounds
            collectionView.collectionViewLayout = flowLayout
            collectionView.isPagingEnabled = true
            collectionView.delegate = strongSelf
            collectionView.dataSource = strongSelf
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: IMContentView.cellID)
        }
        return collectionView
    }()
    
    public init(frame: CGRect, childVCs: [UIViewController], parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.childVCs = childVCs
        super.init(frame: frame)
        
        commontInit()
    }
    
    private func commontInit() {
        for childVC in childVCs {
            if childVC.isKind(of: UINavigationController.self) {
                fatalError("不要添加UINavigationController包装后的子控制器")
            }
            parentViewController?.addChild(childVC)
        }
        
        collectionView.frame = bounds
        addSubview(collectionView)
        
        // 设置naviVVc手势代理, 处理pop手势
        if let naviParentViewController = self.parentViewController?.parent as? UINavigationController,
            let popGesture = naviParentViewController.interactivePopGestureRecognizer {
            naviParentViewController.interactivePopGestureRecognizer?.delegate = self
            // 优先执行naviParentViewController.interactivePopGestureRecognizer的手势
            // 在代理方法中会判断是否真的执行, 不执行的时候就执行scrollView的滚动手势
            collectionView.panGestureRecognizer.require(toFail: popGesture)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        parentViewController = nil
    }
}

extension IMContentView {
    
    /// 给外界可以设置ContentOffSet的方法
    public func setContentOffset(offset: CGPoint, animated: Bool) {
        // 不要执行collectionView的scrollView的滚动代理方法
        self.forbidTouchToAdjustPosition = true
        self.collectionView.setContentOffset(offset, animated: animated)
    }
    
    /// 给外界刷新视图的方法
    public func reloadAllViewsWithNewChildVCs(newChildVCs: [UIViewController]) {
        // removing the old childVcs
        childVCs.forEach({ childVC in
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        })
        
        // setting the new childVcs
        childVCs = newChildVCs
        
        // don't add the childVc that wrapped by the navigationController
        // 不要添加navigationController包装后的子控制器
        for childVC in childVCs {
            if childVC.isKind(of: UINavigationController.self) {
                fatalError("不要添加UINavigationController包装后的子控制器")
            }
             // 添加子控制器
            parentViewController?.addChild(childVC)
        }
        
        // 刷新视图
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension IMContentView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVCs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IMContentView.cellID, for: indexPath)
        // 避免出现重用显示内容出错 ---- 也可以直接给每个cell用不同的reuseIdentifier实现
        // avoid to the case that shows the wrong thing due to the collectionViewCell's reuse
        cell.contentView.subviews.forEach({ $0.removeFromSuperview() })
        let vc = childVCs[indexPath.row]
        vc.view.frame = bounds
        cell.contentView.addSubview(vc.view)
        // finish buildding the parent-child relationship
        vc.didMove(toParent: parentViewController)
        return cell
    }
}

extension IMContentView: UIScrollViewDelegate {
    /// 为了解决在滚动或接着点击title更换的时候因为index不同步而增加了下边的两个代理方法的判断
    ///  滚动减速完成时再更新title的位置
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(floor(scrollView.contentOffset.x / bounds.size.width))
        delegate?.contentViewDidEndMoveToIndex(currentIndex: currentIndex)
    }
    
    /// 手指开始拖的时候, 记录此时的offSetX, 并且表示不是点击title切换的内容
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        oldOffsetX = scrollView.contentOffset.x
        forbidTouchToAdjustPosition = false
        delegate?.contentViewDidBeginMove()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        if forbidTouchToAdjustPosition {
            return
        }
        
        let temp = offsetX / bounds.size.width
        var progress = temp - floor(temp)
        
        if offsetX - oldOffsetX >= 0 {
            if progress == 0.0 {
                return
            }
            
            oldIndex = Int(floor(offsetX / bounds.size.width))
            currentIndex = oldIndex + 1
            if currentIndex >= childVCs.count {
                currentIndex = childVCs.count - 1
                return
            }
        } else {
            currentIndex = Int(floor(offsetX / bounds.size.width))
            oldIndex = currentIndex + 1
            if oldIndex >= childVCs.count {
                oldIndex = childVCs.count - 1
                return
            }
            progress = 1.0 - progress
        }
        delegate?.contentViewMoveToIndex(fromIndex: oldIndex, toIndex: currentIndex, progress: progress)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension IMContentView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
         // 当显示的是ScrollPageView的时候 只在第一个tag处执行pop手势
        if let naviParentViewController = self.parentViewController?.parent as? UINavigationController,
            naviParentViewController.visibleViewController == parentViewController {
            return collectionView.contentOffset.x == 0
        }
        return true
    }
}

/// delegate
public protocol IMContentViewDelegate: class {
    
    /// 有默认实现, 不推荐重写
    func contentViewMoveToIndex(fromIndex: Int, toIndex: Int, progress: CGFloat)
    /// 有默认实现, 不推荐重写
    func contentViewDidEndMoveToIndex(currentIndex: Int)
    /// 无默认操作, 推荐重写
    func contentViewDidBeginMove()
    /// 必须提供的属性
    var segmentView: IMScrollSegmentView { get }
}

// 由于每个遵守这个协议的都需要执行些相同的操作, 所以直接使用协议扩展统一完成,协议遵守者只需要提供segmentView即可
extension IMContentViewDelegate {
    // 默认什么都不做
    public func contentViewDidBeginMove() {
        
    }
    
    // 内容每次滚动完成时调用, 确定title和其他的控件的位置
    public func contentViewDidEndMoveToIndex(currentIndex: Int) {
        segmentView.adjustTitleOffSetToCurrentIndex(currentIndex)
        segmentView.adjustUIWithProgress(1.0, oldIndex: currentIndex, currentIndex: currentIndex)
    }
    
    // 内容正在滚动的时候,同步滚动滑块的控件
    public func contentViewMoveToIndex(fromIndex: Int, toIndex: Int, progress: CGFloat) {
        segmentView.adjustUIWithProgress(progress, oldIndex: fromIndex, currentIndex: toIndex)
    }
}
