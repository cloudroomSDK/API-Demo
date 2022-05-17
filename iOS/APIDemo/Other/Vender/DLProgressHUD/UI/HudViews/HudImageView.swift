//
//  HudImageView.swift
//  DLProgressHUD
//
//  Created by Alonso on 11/12/21.
//

import UIKit

final class HudImageView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = configuration.textNumberOfLines
        label.textAlignment = .center
        label.font = configuration.textFont
        label.textColor = configuration.textColor
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Dependencies

    private let configuration: HudConfigurationProtocol

    private let hudImage: UIImage
    private let descriptionText: String?

    // MARK: - Initializers

    init(configuration: HudConfigurationProtocol, hudImage: UIImage, descriptionText: String? = nil) {
        self.configuration = configuration
        self.hudImage = hudImage
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

        let imageContainterView = UIView()
        imageContainterView.addSubview(imageView)
        imageView.centerInSuperview()
        imageView.constraintHeight(constant: configuration.hudImageHeight)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(greaterThanOrEqualTo: imageContainterView.topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: imageContainterView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainterView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainterView.trailingAnchor)
        ])

        imageView.image = hudImage

        stackView.addArrangedSubview(imageContainterView)
        if let descriptionText = descriptionText {
            let textLabelContainerView = UIView()
            textLabelContainerView.addSubview(textLabel)
            textLabel.fillSuperview(padding: .init(top: 0, left: 8, bottom: 0, right: 8))

            stackView.addArrangedSubview(textLabelContainerView)
            textLabel.text = descriptionText
        }
    }

}
