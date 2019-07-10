//
//  UIViewController+Extension.swift
//  IMScrollPageView
//
//  Created by Mazy on 2019/7/10.
//  Copyright © 2019 Mazy. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public weak var imScrollPageController: UIViewController? {
        get {
            var superVC = self.parent
            while superVC != nil {
//                if superVC is Contiguous
                superVC = superVC?.parent
            }
            return superVC
        }
    }
}
