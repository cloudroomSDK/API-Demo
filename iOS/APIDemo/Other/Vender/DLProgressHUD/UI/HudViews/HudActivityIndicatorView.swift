//
//  HudActivityIndicatorView.swift
//  DLProgressHUD
//
//  Created by Alonso on 3/12/21.
//

import UIKit

final class HudActivityIndicatorView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.color = configuration.activityIndicatorColor
        activityIndicatorView.style = configuration.activityIndicatorStyle
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()

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

    private let descriptionText: String?

    // MARK: - Initializers

    init(configuration: HudConfigurationProtocol, descriptionText: String? = nil) {
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
        addSubview(stackView)
        stackView.centerInSuperview()
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                                     stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor)])

        let activityIndicatorContainerView = UIView()
        activityIndicatorContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerInSuperview()
        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(greaterThanOrEqualTo: activityIndicatorContainerView.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(lessThanOrEqualTo: activityIndicatorContainerView.bottomAnchor),
            activityIndicatorView.leadingAnchor.constraint(greaterThanOrEqualTo: activityIndicatorContainerView.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(lessThanOrEqualTo: activityIndicatorContainerView.trailingAnchor)
        ])

        stackView.addArrangedSubview(activityIndicatorContainerView)
        if let descriptionText = descriptionText {
            let textLabelContainerView = UIView()
            textLabelContainerView.addSubview(textLabel)
            textLabel.fillSuperview(padding: .init(top: 0, left: 8, bottom: 0, right: 8))

            stackView.addArrangedSubview(textLabelContainerView)
            textLabel.text = descriptionText
        }
    }

}
