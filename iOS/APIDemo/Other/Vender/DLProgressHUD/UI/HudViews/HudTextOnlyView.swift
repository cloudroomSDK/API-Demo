//
//  HudTextOnlyView.swift
//  DLProgressHUD
//
//  Created by Alonso on 10/12/21.
//

import UIKit

final class HudTextOnlyView: UIView {

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = configuration.textNumberOfLines
        label.textAlignment = configuration.textAlignment
        label.font = configuration.textFont
        label.textColor = configuration.textColor
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Dependencies

    private let configuration: HudConfigurationProtocol
    private let descriptionText: String

    // MARK: - Initializers

    init(configuration: HudConfigurationProtocol, descriptionText: String) {
        self.configuration = configuration
        self.descriptionText = descriptionText
        super.init(frame: UIScreen.main.bounds)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Private

    private func setupUI() {
        addSubview(textLabel)
        let allowsDynamicTextWidth = configuration.allowsDynamicTextWidth
        let horizontalPadding = allowsDynamicTextWidth ? configuration.horizontalDynamicTextPadding : 8
        textLabel.fillSuperview(padding: .init(top: 8, left: horizontalPadding, bottom: 8, right: horizontalPadding))
        textLabel.text = descriptionText
    }

}
