//
//  ViewController.swift
//  SSL
//
//  Created by Suguru Tokuda on 12/1/23.
//

import UIKit

class ViewController: UIViewController {
    lazy var screenTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SSL App"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var endpointLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Endpoint"
        return label
    }()
    
    lazy var endpointTextField: UITextField = {
        let textField = UITextField()
        textField.text = Constants.serverUrl
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var endpointLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var connectBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.setTitleColor(.label, for: .normal)
        btn.layer.borderColor = UIColor.systemBlue.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        btn.layer.backgroundColor = UIColor.systemBlue.cgColor
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setTitle("Connect", for: .normal)
    
        return btn
    }()
    
    lazy var pinningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pinning Enabled"
        return label
    }()
    
    lazy var pinningSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    lazy var pinningStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension ViewController {
    private func setupUI() {
        view.addSubview(screenTitle)
        view.addSubview(stackView)
        
        endpointLabelStackView.addArrangedSubview(endpointLabel)
        endpointLabelStackView.addArrangedSubview(endpointTextField)
        
        pinningStackView.addArrangedSubview(pinningLabel)
        pinningStackView.addArrangedSubview(pinningSwitch)
        
        stackView.addArrangedSubview(endpointLabelStackView)
        stackView.addArrangedSubview(pinningStackView)
        stackView.addArrangedSubview(connectBtn)
        
        connectBtn.addTarget(self, action: #selector(handleConnectBtnTap), for: .touchUpInside)
        
        applyConstraints()
    }
    
    private func applyConstraints() {
        let screenTitleConstraints = [
            screenTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.2)
        ]
        
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ]
        
        NSLayoutConstraint.activate(screenTitleConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
    }
}

extension ViewController {
    @objc func handleConnectBtnTap() {
        let networkManager = NetworkManager(pinning: self.pinningSwitch.isOn)
        networkManager.makeRequest(urlString: endpointTextField.text ?? Constants.serverUrl)
    }
}
