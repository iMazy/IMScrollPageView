//
//  IMSegmentStyle.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

public struct IMSegmentStyle {
 
    /// 是否显示遮盖
    public var isShowCover: Bool = false
    /// 是否显示下划线
    public var isShowScrollLine: Bool = false
    /// 是否缩放文字
    public var isTitleScale: Bool = false
    /// 是否可以滚动标题
    public var isTitleScroll: Bool = true
    /// 是否颜色渐变
    public var isChangeTitleColorGradual: Bool = false
    /// 是否显示附加的按钮 默认为false
    public var isShowExtraButton: Bool = false
    /// 点击title切换内容的时候是否有动画 默认为true
    public var isAnimatedChangeContent: Bool = true
    /// 额外按钮的背景图片名称
    public var extraButtonBgImageName: String?
    /// 下面的滚动条的高度 默认2
    public var bottomLineHeight: CGFloat = 2
    /// 下面的滚动条的颜色
    public var bottomLineColor: UIColor = UIColor.red
    /// 遮盖的背景颜色
    public var coverBackgroundColor: UIColor = UIColor.lightGray
    /// 遮盖圆角
    public var coverCornerRadius: CGFloat = 14
    /// cover的高度 默认28
    public var coverHeight: CGFloat = 28
    /// 文字间的间隔 默认15
    public var titleMargin: CGFloat = 15
    /// 文字间的间隔 默认15
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// 放大倍数 默认1.3
    public var titleBigScale: CGFloat = 1.3
    /// 默认倍数 不可修改
    let titleOriginalScale: CGFloat = 1.0
    
    /// 文字正常状态颜色 请使用RGB空间的颜色值!! 如果提供的不是RGB空间的颜色值就可能crash
    public var titleNormalColor: UIColor = UIColor(red: 51.0/255.0, green: 53.0/255.0, blue: 75/255.0, alpha: 1.0)
    /// 文字选中状态颜色 请使用RGB空间的颜色值!! 如果提供的不是RGB空间的颜色值就可能crash
    public var titleSelectColor: UIColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 121/255.0, alpha: 1.0)
    
    public init() {
        
    }
}
