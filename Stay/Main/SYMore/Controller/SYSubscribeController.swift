//
//  SYSubscribeController.swift
//  Stay
//
//  Created by King on 23/7/2022.
//

import UIKit

class SYSubscribeController: UIViewController {
    
    let lifeBtn = UIControl()
    let payBtn = UIControl()
    let payLabel = UILabel()
    let trailLabel = UILabel()
    let loadingView = LoadingView()
    
    var product: FCProduct? = nil
    var productDic: [String: FCProduct] = [String: FCProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = FCStyle.background
        self.title = NSLocalizedString("Upgrade", comment: "")
        #if Mac
        let barItem = UIBarButtonItem(title:NSLocalizedString("settings.close", comment: "") , style: .plain, target: self, action: #selector(cancelAction))
        barItem.tintColor = FCStyle.accent
        navigationItem.leftBarButtonItem = barItem
        #endif
        
        let features = [
            FeatureItem(icon: UIImage(systemName: "square.and.arrow.down.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))!.withTintColor(FCStyle.accent).withRenderingMode(.alwaysOriginal), title: NSLocalizedString("DownloaderFeature", comment: ""), desc: NSLocalizedString("DownloaderFeatureDesc", comment: "")),
            FeatureItem(icon: UIImage(systemName: "icloud.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))!.withTintColor(FCStyle.accent).withRenderingMode(.alwaysOriginal), title: NSLocalizedString("iCloudFeature", comment: ""), desc: NSLocalizedString("iCloudFeatureDesc", comment: "")),
            FeatureItem(icon: UIImage(systemName: "moon.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))!.withTintColor(FCStyle.accent).withRenderingMode(.alwaysOriginal), title: NSLocalizedString("DarkModeFeature", comment: ""), desc: NSLocalizedString("DarkModeFeatureDesc", comment: "")),
            FeatureItem(icon: UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))!.withTintColor(FCStyle.accent).withRenderingMode(.alwaysOriginal), title: NSLocalizedString("IndieFeature", comment: ""), desc: NSLocalizedString("IndieFeatureDesc", comment: "")),
            FeatureItem(icon: UIImage(systemName: "arrow.up.forward.square.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 23)))!.withTintColor(FCStyle.accent).withRenderingMode(.alwaysOriginal), title: NSLocalizedString("PromotFeature", comment: ""), desc: NSLocalizedString("PromotFeatureDesc", comment: "")),
        ]
        let featureView = FeatureView(frame: .zero, features: features)
        view.addSubview(featureView)
        
        lifeBtn.layer.cornerRadius = 10
        lifeBtn.backgroundColor = FCStyle.accent.withAlphaComponent(0.1)
        lifeBtn.tag = 0
        lifeBtn.addTarget(self, action: #selector(planAction), for: .touchUpInside)
        lifeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lifeBtn)
        FCStore.shared().productsRequest { productDic in
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                
                self.productDic = productDic
                self.product = productDic["lifetime"]
                self.updatePayState()
                
                if let product = productDic["lifetime"] {
                    let titleLabel = UILabel()
                    titleLabel.font = FCStyle.footnote
                    titleLabel.textColor = FCStyle.fcSecondaryBlack
                    titleLabel.text = product.localizedTitle
                    titleLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.lifeBtn.addSubview(titleLabel)
                    let priceLabel = UILabel()
                    priceLabel.font = FCStyle.body
                    priceLabel.textColor = FCStyle.fcBlack
                    priceLabel.text = product.localizedPrice
                    priceLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.lifeBtn.addSubview(priceLabel)
                    NSLayoutConstraint.activate([
                        
                        titleLabel.leadingAnchor.constraint(equalTo: self.lifeBtn.leadingAnchor, constant: 16),
                        titleLabel.topAnchor.constraint(equalTo: self.lifeBtn.topAnchor, constant: 7),
                        priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                        priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                        
                    ])
                }
            }
        }
        
        payBtn.backgroundColor = FCStyle.backgroundGolden
        payBtn.layer.borderColor = FCStyle.borderGolden.cgColor
        payBtn.layer.borderWidth = 1
        payBtn.layer.cornerRadius = 7
        payBtn.tag = 3
        payBtn.addTarget(self, action: #selector(planAction), for: .touchUpInside)
        payBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(payBtn)
        payLabel.font = FCStyle.bodyBold
        payLabel.textColor = FCStyle.fcGolden
        payLabel.translatesAutoresizingMaskIntoConstraints = false
        payBtn.addSubview(payLabel)
        payLabel.centerXAnchor.constraint(equalTo: payBtn.centerXAnchor).isActive = true
        payLabel.centerYAnchor.constraint(equalTo: payBtn.centerYAnchor).isActive = true
        
        let restoreBtn = UIButton()
        restoreBtn.setTitleColor(FCStyle.accent, for: .normal)
        restoreBtn.setTitle(NSLocalizedString("Restore", comment: ""), for: .normal)
        restoreBtn.titleLabel?.font = FCStyle.footnote
        restoreBtn.tag = 4
        restoreBtn.addTarget(self, action: #selector(planAction), for: .touchUpInside)
        restoreBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(restoreBtn)
        
        trailLabel.font = FCStyle.footnote
        trailLabel.textColor = FCStyle.fcSecondaryBlack
        trailLabel.text = " "
        trailLabel.textAlignment = .center
        trailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trailLabel)
        
        let privacyBtn = UIButton()
        privacyBtn.setTitle(NSLocalizedString("PrivacyPolicy", comment: ""), for: .normal)
        privacyBtn.setTitleColor(FCStyle.fcBlack, for: .normal)
        privacyBtn.titleLabel?.font = FCStyle.footnote
        privacyBtn.addTarget(self, action: #selector(privacyAction), for: .touchUpInside)
        privacyBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(privacyBtn)
        let lineLabel = UILabel()
        lineLabel.font = FCStyle.footnote
        lineLabel.textColor = FCStyle.fcBlack
        lineLabel.text = " - "
        lineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineLabel)
        let termBtn = UIButton()
        termBtn.setTitle(NSLocalizedString("TermsOfUse", comment: ""), for: .normal)
        termBtn.setTitleColor(FCStyle.fcBlack, for: .normal)
        termBtn.titleLabel?.font = FCStyle.footnote
        termBtn.addTarget(self, action: #selector(termAction), for: .touchUpInside)
        termBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(termBtn)
        
        NSLayoutConstraint.activate([
            featureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            featureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            featureView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            featureView.heightAnchor.constraint(equalToConstant: 66 * 5),
            
            lifeBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            lifeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            lifeBtn.topAnchor.constraint(equalTo: featureView.bottomAnchor, constant: 14),
            lifeBtn.heightAnchor.constraint(equalToConstant: 60),
            
            payBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            payBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            payBtn.topAnchor.constraint(equalTo: lifeBtn.bottomAnchor, constant: 20),
            payBtn.heightAnchor.constraint(equalToConstant: 40),
            restoreBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restoreBtn.topAnchor.constraint(equalTo: payBtn.bottomAnchor, constant: 10),
            trailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trailLabel.topAnchor.constraint(equalTo: restoreBtn.bottomAnchor, constant: 11),
            privacyBtn.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            privacyBtn.topAnchor.constraint(equalTo: trailLabel.bottomAnchor, constant: 13),
            lineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineLabel.centerYAnchor.constraint(equalTo: privacyBtn.centerYAnchor),
            termBtn.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            termBtn.topAnchor.constraint(equalTo: privacyBtn.topAnchor),
        ])
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func updatePayState() {
        if product != nil {
            if FCStore.shared().subscribed(product!.productIdentifier)  {
                payBtn.isEnabled = false
                payBtn.backgroundColor = FCStyle.tertiaryBackground
                payBtn.layer.borderColor = UIColor(named: "BorderColor")!.cgColor
                payLabel.textColor = FCStyle.fcSecondaryBlack
                payLabel.text = NSLocalizedString("Subscribed", comment: "")
                trailLabel.text = product?.introductoryOffer
            } else {
                payBtn.isEnabled = true
                payBtn.backgroundColor = FCStyle.backgroundGolden
                payBtn.layer.borderColor = FCStyle.borderGolden.cgColor
                payLabel.textColor = FCStyle.fcGolden
                payLabel.text = String(format: NSLocalizedString("ContinuePay", comment: ""), product!.localizedTitle)
                trailLabel.text = product?.introductoryOffer
            }
        }
    }
    
    @objc
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func planAction(sender: UIControl) {
        switch (sender.tag) {
        case 3:
            if product != nil {
                self.loadingView.isHidden = false
                FCStore.shared().pay(product!) { state in
                    DispatchQueue.main.async {
                        if state != FCPaymentStateInProgress {
                            self.loadingView.isHidden = true
                        }
                        
                        if state == FCPaymentStatePurchased {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "app.stay.notification.SYSubscibeChangeNotification"), object: nil)
                            self.updatePayState()
                        } else {
                            print("failed")
                        }
                    }
                }
            }
        case 4:
            self.loadingView.isHidden = false
            FCStore.shared().restore { state in
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    
                    if state == FCPaymentStateRestored {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "app.stay.notification.SYSubscibeChangeNotification"), object: nil)
                        self.updatePayState()
                    } else {
                        print("failed")
                    }
                }
            }
        default:
            return
        }
    }
    
    @objc
    func privacyAction() {
        if let url = URL(string: "https://www.privacypolicyonline.com/live.php?token=ZPXT0Jfv2diYUfbf5ciLDV9oYRgJ6Evc") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc
    func termAction() {
        if let url = URL(string: "https://fastclip.app/policy/terms-stay.htm") {
            UIApplication.shared.open(url)
        }
    }

}

class FeatureView : UIView {
    
    let features: [FeatureItem]
    
    init(frame: CGRect, features: [FeatureItem]) {
        self.features = features
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        for (i, item) in features.enumerated() {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(container)
            
            let icon = UIImageView()
            icon.image = item.icon
            icon.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(icon)
            let title = UILabel()
            title.font = FCStyle.headlineBold
            title.textColor = FCStyle.fcBlack
            title.text = item.title
            title.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(title)
            let desc = UILabel()
            desc.font = FCStyle.footnote
            desc.textColor = FCStyle.fcSecondaryBlack
            desc.text = item.desc
            desc.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(desc)
            
            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                container.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(i * 66)),
                container.heightAnchor.constraint(equalToConstant: 66),
                icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
                icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 66),
                title.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
                desc.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                desc.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct FeatureItem {
    
    let icon: UIImage
    let title: String
    let desc: String
    
}

class LoadingView : UIView {
    
    let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = FCStyle.fcBlack.withAlphaComponent(0.1)
        
        let container = UIView()
        container.backgroundColor = FCStyle.secondaryBackground
        container.layer.cornerRadius = 6
        container.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(container)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            container.widthAnchor.constraint(equalToConstant: 66),
            container.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 66),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
