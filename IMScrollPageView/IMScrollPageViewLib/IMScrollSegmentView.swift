//
//  IMScrollSegmentView.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

public class IMScrollSegmentView: UIView {

    public var segmentStyle: IMSegmentStyle
    /// 所有的标题
    private var titles: [String]
    
    public var titleButtonClickClosure: ((_ label: UILabel, _ index: Int) -> Void)?
    @objc public var extraButtonClickClosure: ((_ extraButton: UIButton) -> Void)?
    
    private var currentWidth: CGFloat = 0
    
    private var xGap: Int = 5
    
    private var wWap: Int {
        return 2 * xGap
    }
    
    private var labelsArray: [UILabel] = []
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
    
    private lazy var rebDelta: (deltaR: CGFloat, deltaG: CGFloat, deltaB: CGFloat) = {
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
        
        addSubview(scrollView)
        
        if let extraBtn = extraButton {
            addSubview(extraBtn)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
