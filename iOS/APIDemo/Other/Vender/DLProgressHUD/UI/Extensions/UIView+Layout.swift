//
//  UIView+Layout.swift
//  DLProgressHUD
//
//  Created by Alonso on 21/12/21.
//

import UIKit

extension UIView {

    func fillSuperview(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: padding.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding.bottom),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding.right)
        ])
    }

    func horizontalMarginInSuperview(margin: CGFloat) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: margin),
            trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -margin)
        ])
    }

    func centerInSuperview(size: CGSize = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    func constraintWidth(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }

    func constraintHeight(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }

}
