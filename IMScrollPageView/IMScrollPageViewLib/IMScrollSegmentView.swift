//
//  IMScrollSegmentView.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

protocol IMScrollSegmentViewDelegate: class {
    func scrollSegmentViewTitleButtonClick(with label: UILabel, index: Int)
}

public class IMScrollSegmentView: UIView {

    public var segmentStyle: IMSegmentStyle
    /// 所有的标题
    private var titles: [String]
    
    weak var delegate: IMScrollSegmentViewDelegate?
//    public var titleButtonClickClosure: ((_ label: UILabel, _ index: Int) -> Void)?
    @objc public var extraButtonClickClosure: ((_ extraButton: UIButton) -> Void)?
    
    private var currentWidth: CGFloat = 0
    
    private var xGap: Int = 5
    
    private var wGap: Int {
        return 2 * xGap
    }
    
    private var labelsArray: [IMCustomLabel] = []
    private var currentIndex: Int = 0
    private var oldIndex: Int = 0
    private var titlesWidthArray: [CGFloat] = []
    
    private lazy var scrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.bounces = true
        scrollV.isPagingEnabled = false
        scrollV.scrollsToTop = false
        return scrollV
    }()
    
    private lazy var scrollLine: UIView? = { [unowned self] in
        return self.segmentStyle.isShowScrollLine ? UIView() : nil
    }()
    
    private lazy var coverLayer: UIView? = {  [unowned self] in
        if  !self.segmentStyle.isShowCover {
            return nil
        }
        let cover = UIView()
        cover.layer.cornerRadius = self.segmentStyle.coverCornerRadius
        cover.layer.masksToBounds = true
        return cover
    }()
    
    private lazy var extraButton: UIButton? = {
        if !self.segmentStyle.isShowExtraButton {
            return nil
        }
        let button = UIButton()
        button.addTarget(self, action: #selector(getter: self.extraButtonClickClosure), for: .touchUpInside)
        if let imageName = self.segmentStyle.extraButtonBgImageName {
            button.setImage(UIImage(named: imageName), for: .normal)
        }
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOffset = CGSize(width: -5, height: 0)
        button.layer.shadowOpacity = 1
        return button
    }()
    
    private func getRGBColor(color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        let components = color.cgColor.components
        if components?.count == 4 {
            return (r: components?[0], g: components?[1], b: components?[2]) as? (r: CGFloat, g: CGFloat, b: CGFloat)
        }
        return nil
    }
    
    private lazy var normalColorRGB: (r: CGFloat, g: CGFloat, b: CGFloat) = {
        if let normalRgb = self.getRGBColor(color: self.segmentStyle.titleNormalColor) {
            return normalRgb
        } else {
            fatalError("设置普通状态的文字颜色时 请使用RGB空间的颜色值")
        }
    }()
    
    private lazy var selectedTitleColorRGB: (r: CGFloat, g: CGFloat, b: CGFloat) = {
        if let selectedRgb = self.getRGBColor(color: self.segmentStyle.titleSelectColor) {
            return selectedRgb
        } else {
            fatalError("设置选中状态的文字颜色时 请使用RGB空间的颜色值")
        }
    }()
    
    private lazy var rgbDelta: (deltaR: CGFloat, deltaG: CGFloat, deltaB: CGFloat) = {
        let normalColorRgb = self.normalColorRGB
        let selectColorRgb = self.selectedTitleColorRGB
        let deltaR = normalColorRGB.r - selectColorRgb.r
        let deltaG = normalColorRGB.g - selectColorRgb.g
        let deltaB = normalColorRGB.b - selectColorRgb.b
        return  (deltaR: deltaR, deltaG: deltaG, deltaB: deltaB)
    }()
    
    private lazy var backgroundImageView: UIImageView = { [unowned self] in
        return UIImageView(frame: self.bounds)
    }()

    
    public var backgroundImage: UIImage? = nil {
        didSet {
            if let image = backgroundImage {
                backgroundImageView.image = image
                insertSubview(backgroundImageView, at: 0)
            }
        }
    }
    
    public init(frame: CGRect, titles: [String], segmentStyle: IMSegmentStyle) {
        self.segmentStyle = segmentStyle
        self.titles = titles
        super.init(frame: frame)
        
        if !segmentStyle.isTitleScroll {
            self.segmentStyle.isTitleScale = !(segmentStyle.isShowCover || segmentStyle.isShowScrollLine)
        }
        
        addSubview(scrollView)
        
        if let extraBtn = extraButton {
            addSubview(extraBtn)
        }
        
        setupTitles()
        setupUI()
    }
    
    @objc func titleLabelClickAction(tapGesture: UITapGestureRecognizer) {
        guard let currentLabel = tapGesture.view as? IMCustomLabel else { return }
        currentIndex = currentLabel.tag

        adjustUIWhenButtonClick(animated: true)
    }
    
    func extraButtonClickAction(sender: UIButton) {
        extraButtonClickClosure?(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IMScrollSegmentView {
    public func selectedIndex(_ index: Int, animated: Bool) {
        assert(index <= 0 || index > titles.count, "设置的下标不合法!")
        if index < 0 || index >= titles.count {
            return
        }
        // 自动调整到相应的位置
        currentIndex = index
        
        // 可以改变设置下标滚动后是否有动画切换效果
        adjustUIWhenButtonClick(animated: animated)
    }
    
    public func reloadTitlesWithNewTitles(_ titles: [String]) {
        // 移除所有的scrollView子视图
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        // 移除所有的label相关
        titlesWidthArray.removeAll()
        labelsArray.removeAll()
        
        // 重新设置UI
        self.titles = titles
        setupTitles()
        setupUI()
        // default selecte the first tag
        selectedIndex(0, animated: true)
    }
}

extension IMScrollSegmentView {
    
    private func setupTitles() {
        for (index, title) in titles.enumerated() {
            
            let label = IMCustomLabel(frame: .zero)
            label.tag = index
            label.text = title
            label.textColor = segmentStyle.titleNormalColor
            label.font = segmentStyle.titleFont
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            
            // 添加点击手势
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClickAction(tapGesture:)))
            label.addGestureRecognizer(tapGesture)
            
            // 计算文字尺寸
            let size = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font], context: nil)
            // 缓存文字宽度
            titlesWidthArray.append(size.width)
            // 缓存label
            labelsArray.append(label)
            // 添加label
            scrollView.addSubview(label)
        }
    }
    
    private func setupUI() {
        // 设置extra按钮
        setupScrollViewAndExtraButton()
        // 先设置label的位置
        setupLabelsPosition()
        // 再设置滚动条和cover的位置
        setupScrollLineViewAndConver()
        
        if segmentStyle.isTitleScroll { // 设置滚动区域
            if let lastLabel = labelsArray.last {
                scrollView.contentSize = CGSize(width: lastLabel.frame.maxX + segmentStyle.titleMargin, height: 0)
            }
        }
    }
    
    private func setupScrollViewAndExtraButton() {
        currentWidth = self.bounds.width
        let extraButtonW: CGFloat = 44.0
        let extraButtonY: CGFloat = 5.0
        let scrollWidth = extraButton == nil ? currentWidth : currentWidth - extraButtonW
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollWidth, height: bounds.size.height)
        extraButton?.frame = CGRect(x: scrollWidth, y: extraButtonY, width: extraButtonW, height: bounds.size.height  - extraButtonY * 2)
    }
    
    private func setupLabelsPosition() {
        
        var titleX: CGFloat = 0
        let titleY: CGFloat = 0
        var titleW: CGFloat = 0
        let titleH: CGFloat = bounds.size.height - segmentStyle.bottomLineHeight
        
        if !segmentStyle.isTitleScroll { // 标题不能滚动, 平分宽度
            titleW = currentWidth / CGFloat(titles.count)
            
            for (index, label) in labelsArray.enumerated() {
                titleX = CGFloat(index) * titleW
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            }
        } else {
            for (index, label) in labelsArray.enumerated() {
                titleW = titlesWidthArray[index]
                titleX = segmentStyle.titleMargin
                if index != 0 {
                    let lastLabel = labelsArray[index - 1]
                    titleX = (lastLabel.frame.maxX) + segmentStyle.titleMargin
                }
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            }
        }
        
        if let firstLabel = labelsArray.first {
            // 缩放, 设置初始的label的transform
            if segmentStyle.isTitleScale {
                firstLabel.currentTransformScale = segmentStyle.titleBigScale
            }
            // 设置初始状态文字的颜色
            firstLabel.textColor = segmentStyle.titleSelectColor
        }
    }
    
    private func setupScrollLineViewAndConver() {
        if let line = scrollLine {
            line.backgroundColor = segmentStyle.bottomLineColor
            scrollView.addSubview(line)
        }
        if let cover = coverLayer {
            cover.backgroundColor = segmentStyle.coverBackgroundColor
            scrollView.insertSubview(cover, at: 0)
        }
        let coverX = labelsArray[0].frame.origin.x
        let coverW = labelsArray[0].frame.size.width
        let coverH: CGFloat = segmentStyle.coverHeight
        let coverY = (bounds.size.height - coverH) / 2
        if segmentStyle.isTitleScroll {
            // 这里x-xGap width+wGap 是为了让遮盖的左右边缘和文字有一定的距离
            coverLayer?.frame = CGRect(x: coverX - CGFloat(xGap), y: coverY, width: coverW + CGFloat(wGap), height: coverH)
        } else {
            coverLayer?.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        }
        
        scrollLine?.frame = CGRect(x: coverX, y: bounds.size.height - segmentStyle.bottomLineHeight, width: coverW, height: segmentStyle.bottomLineHeight)
    }
}

extension IMScrollSegmentView {
    
    public func adjustUIWhenButtonClick(animated: Bool) {
        if currentIndex == oldIndex { return }
        let oldLabel = labelsArray[oldIndex]
        let currentLabel = labelsArray[currentIndex]
        
        adjustTitleOffSetToCurrentIndex(currentIndex)
        
        let animationDuration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: animationDuration) {
            // 设置文字颜色
            oldLabel.textColor = self.segmentStyle.titleNormalColor
            currentLabel.textColor = self.segmentStyle.titleSelectColor
            
            // 缩放文字
            if self.segmentStyle.isTitleScale {
                oldLabel.currentTransformScale = self.segmentStyle.titleOriginalScale
                currentLabel.currentTransformScale = self.segmentStyle.titleBigScale
            }
            
            // 设置滚动条的位置
            self.scrollLine?.frame.origin.x = currentLabel.frame.origin.x
            // 注意, 通过bounds 获取到的width 是没有进行transform之前的 所以使用frame
            self.scrollLine?.frame.size.width = currentLabel.frame.size.width
            
            // 设置遮盖位置
            if self.segmentStyle.isTitleScroll {
                self.coverLayer?.frame.origin.x = currentLabel.frame.origin.x - CGFloat(self.xGap)
                self.coverLayer?.frame.size.width = currentLabel.frame.size.width + CGFloat(self.wGap)
            } else {
                self.coverLayer?.frame.origin.x = currentLabel.frame.origin.x
                self.coverLayer?.frame.size.width = currentLabel.frame.size.width
            }
        }
        oldIndex = currentIndex
        delegate?.scrollSegmentViewTitleButtonClick(with: currentLabel, index: currentIndex)
    }
    
    // 手动滚动时需要提供动画效果
    public func adjustUIWithProgress(_ progress: CGFloat, oldIndex: Int, currentIndex: Int) {
        // 记录当前的currentIndex以便于在点击的时候处理
        self.oldIndex = oldIndex
        
        let oldLabel = labelsArray[oldIndex]
        let currentLabel = labelsArray[currentIndex]
        
        // 从一个label滚动到另一个label 需要改变的总的距离 和 总的宽度
        let xDistance = currentLabel.frame.origin.x - oldLabel.frame.origin.x
        let wDistance = currentLabel.frame.size.width - oldLabel.frame.size.width
        
        // 设置滚动条位置 = 最初的位置 + 改变的总距离 * 进度
        scrollLine?.frame.origin.x = oldLabel.frame.origin.x + xDistance * progress
        // 设置滚动条宽度 = 最初的宽度 + 改变的总宽度 * 进度
        scrollLine?.frame.size.width = oldLabel.frame.size.width + wDistance * progress
        
        // 设置 cover 位置
        if segmentStyle.isTitleScroll {
            coverLayer?.frame.origin.x = oldLabel.frame.origin.x + xDistance * progress - CGFloat(xGap)
            coverLayer?.frame.size.width = oldLabel.frame.size.width + wDistance * progress + CGFloat(wGap)
        } else {
            coverLayer?.frame.origin.x = oldLabel.frame.origin.x + xDistance * progress
            coverLayer?.frame.size.width = oldLabel.frame.size.width + wDistance * progress
        }
        
        // 文字颜色渐变
        if segmentStyle.isChangeTitleColorGradual {
            oldLabel.textColor = UIColor(red: selectedTitleColorRGB.r + rgbDelta.deltaR * progress, green: selectedTitleColorRGB.g + rgbDelta.deltaG * progress, blue: selectedTitleColorRGB.b + rgbDelta.deltaB * progress, alpha: 1.0)
            
            currentLabel.textColor =  UIColor(red: normalColorRGB.r - rgbDelta.deltaR * progress, green: normalColorRGB.g - rgbDelta.deltaG * progress, blue: normalColorRGB.b - rgbDelta.deltaB * progress, alpha: 1.0)
        }
        
        // 缩放文字
        if !segmentStyle.isTitleScale {
            return
        }
        
        // 注意左右间的比例是相关连的, 加减相同
        // 设置文字缩放
        let deltaScale = (segmentStyle.titleBigScale - segmentStyle.titleOriginalScale)
        oldLabel.currentTransformScale = segmentStyle.titleBigScale - deltaScale * progress
        currentLabel.currentTransformScale = segmentStyle.titleOriginalScale + deltaScale * progress
    }
    
    // 居中显示title
    public func adjustTitleOffSetToCurrentIndex(_ index: Int) {
        let currentLabel = labelsArray[index]
        labelsArray.enumerated().forEach { [unowned self] in
            if $0.offset != index {
                $0.element.textColor = self.segmentStyle.titleNormalColor
            }
        }
        // 目标是让currentLabel居中显示
        var offsetX = currentLabel.center.x - currentWidth / 2
        if offsetX < 0 {
            offsetX = 0
        }
        // considering the exist of extraButton
        let extraButtonW = extraButton?.frame.size.width ?? 0.0
        var maxOffsetX = scrollView.contentSize.width - (currentWidth - extraButtonW)
        
        // 可以滚动的区域小余屏幕宽度
        if maxOffsetX < 0 {
            maxOffsetX = 0
        }
        
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // 没有渐变效果的时候设置切换title时的颜色
        if !segmentStyle.isChangeTitleColorGradual {
            for (index, label) in labelsArray.enumerated() {
                if index == currentIndex {
                    label.textColor = segmentStyle.titleSelectColor
                } else {
                    label.textColor = segmentStyle.titleNormalColor
                }
            }
        }
    }
}

/// custom label
public class IMCustomLabel: UILabel {
    
    /// 用来记录当前label的缩放比例
    public var currentTransformScale: CGFloat = 1.0 {
        didSet {
            transform = CGAffineTransform(scaleX: currentTransformScale, y: currentTransformScale)
        }
    }
}
