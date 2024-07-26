//
//  DeleteAlertView.swift
//  FakeNFT
//
//  Created by Александр Плешаков on 25.07.2024.
//

import UIKit
import SnapKit
import Kingfisher

final class DeleteAlertView: UIView {
    // MARK: Properties

    private let mainView = UIView()

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12

        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.segmentActive
        label.textAlignment = .center
        label.font = UIFont.caption2
        label.numberOfLines = 0
        label.text = NSLocalizedString(
            "Вы уверены, что хотите удалить объект из корзины?",
            comment: ""
        )

        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 127, height: 44)
        button.backgroundColor = UIColor.segmentActive
        button.setTitleColor(UIColor.background, for: .normal)
        button.setTitle(
            NSLocalizedString("Вернуться", comment: ""),
            for: .normal
        )
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.bodyRegular

        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 127, height: 44)
        button.backgroundColor = UIColor.segmentActive
        button.setTitleColor(UIColor.textRed, for: .normal)
        button.setTitle(
            NSLocalizedString("Удалить", comment: ""),
            for: .normal
        )
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.bodyRegular

        return button
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually

        return stack
    }()

    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    // MARK: Init

    init() {
        super.init(frame: .zero)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods

    @objc private func dismissAlert() {
        print("dismiss")
        animateViewDismissing()
        self.isHidden = true
    }

    func show(on viewController: UIViewController, with height: CGFloat, image: URL) {
        self.isHidden = false
        blurEffectView.layer.opacity = 0
        mainView.layer.opacity = 0
        mainView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        if !self.isDescendant(of: viewController.view) {
            add(on: viewController, with: height)
        }
        animateViewAppearance(on: viewController)
        nftImageView.kf.setImage(with: image)

        addTargetForButtons()
    }

    func addTargetForButtons() {
        backButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
    }

    private func add(on viewController: UIViewController, with height: CGFloat) {
        mainView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(height * 0.32)
        }

        guard let view = viewController.view else { return }
        view.addSubview(self)

        snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }

    private func animateViewDismissing() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { [weak self] in
            guard let self else { return }
            mainView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            mainView.layer.opacity = 0
        }, completion: { [weak self] isCompleted in
            if isCompleted {
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: [.curveEaseInOut],
                               animations: { [weak self] in
                    self?.blurEffectView.layer.opacity = 0
                })
            }
        })
    }

    private func animateViewAppearance(on viewController: UIViewController) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveLinear],
                       animations: { [weak self] in
            guard let self else { return }
            blurEffectView.layer.opacity = 1
        }, completion: { [weak self] isCompleted in
            if isCompleted {
                viewController.navigationController?.navigationBar.isHidden = true
                viewController.tabBarController?.tabBar.isHidden = true

                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseInOut],
                               animations: { [weak self] in
                    guard let self else { return }
                    mainView.transform = CGAffineTransform.identity
                    mainView.layer.opacity = 1
                })
            }
        })
    }

    private func setupSubviews() {
        setupBlur()
        [textLabel, nftImageView, buttonsStack].forEach {
            mainView.addSubview($0)
        }
        addSubview(mainView)

        isUserInteractionEnabled = true
        mainView.isUserInteractionEnabled = true
        buttonsStack.isUserInteractionEnabled = true
        backButton.isUserInteractionEnabled = true

        setupImageView()
        setupLabel()
        setupButtons()
        setupMainView()

    }

    private func setupMainView() {
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.centerX.equalToSuperview()
            make.leading.lessThanOrEqualToSuperview().inset(57)
            make.trailing.lessThanOrEqualToSuperview().inset(57)
        }
    }

    private func setupBlur() {
        addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.bottom.equalTo(snp.bottom) }
    }

    private func setupImageView() {
        nftImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(108)
        }
    }

    private func setupLabel() {
        let labelWidth = 180
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(nftImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(labelWidth)
        }
    }

    private func setupButtons() {
//        mainView.addSubview(backButton)
//
//        backButton.snp.makeConstraints { make in
//            make.width.equalTo(127)
//            make.height.equalTo(44)
//            make.top.equalTo(textLabel.snp.bottom).offset(20)
//            make.trailing.equalToSuperview()
//        }

        buttonsStack.addArrangedSubview(deleteButton)
        buttonsStack.addArrangedSubview(backButton)

        let buttonHeight = 44
        let hStackWidth = 262
        buttonsStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(textLabel.snp.bottom).offset(20)
            make.width.equalTo(hStackWidth)
            make.height.equalTo(buttonHeight)
        }

    }

}
