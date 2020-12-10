//
//  UIViewController+Storyboard.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import UIKit

extension UIViewController {
    static func createFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let type = String(describing: Self.self)
        let vc = storyboard.instantiateViewController(identifier: String(describing: type)) as Self
        return vc
    }
}
