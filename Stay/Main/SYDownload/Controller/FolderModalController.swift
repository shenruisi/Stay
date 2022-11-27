//
//  FolderModalController.swift
//  Stay
//
//  Created by Jin on 2022/11/27.
//

import UIKit

class FolderModalController: ModalViewController, UITextFieldDelegate {

    var folderTab: FCTab?
    
    init(folderTab: FCTab?) {
        self.folderTab = folderTab
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let titleContainer = UIStackView()
    let titlePreview = UIView()
    let titleLabel = UILabel()
    let nameContainer = RoundedBorderView()
    let nameInput = UITextField()
    let colorContainer = RoundedBorderView()
    let focusView = UIView()
    let hexInput = UITextField()
    let redInput = UITextField()
    let greenInput = UITextField()
    let blueInput = UITextField()
    let previewView = UIView()
    
    let globalColors = [
        "D91D06","FA6400","F7B500","6DD400","44D7B6","32C5FF",
        "0091FF","6236FF","B620E0","6D7278","E5E5E5","000000"
    ]
    var selectedColorIndex = 0
    var selectedColor = "D91D06"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FCStyle.popup
        
        titleContainer.axis = .horizontal
        titleContainer.alignment = .center
        titleContainer.spacing = 8
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleContainer)
        titlePreview.layer.cornerRadius = 8
        titlePreview.clipsToBounds = true
        titleContainer.addArrangedSubview(titlePreview)
        titleLabel.textColor = FCStyle.fcBlack
        titleLabel.font = FCStyle.bodyBold
        titleContainer.addArrangedSubview(titleLabel)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameContainer)
        nameInput.textColor = FCStyle.fcBlack
        nameInput.font = FCStyle.body
        nameInput.placeholder = NSLocalizedString("PinName", comment: "")
        nameInput.autocorrectionType = .no
        nameInput.delegate = self
        nameInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        nameInput.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameInput)
        if folderTab != nil {
            selectedColorIndex = -1
            selectedColor = folderTab!.config.hexColor
            if selectedColor.isEmpty {
                selectedColorIndex = 0
                selectedColor = "D91D06"
            }
            nameInput.text = folderTab?.config.name
            for (index, color) in globalColors.enumerated() {
                if color == folderTab?.config.hexColor {
                    selectedColorIndex = index
                    break
                }
            }
        }
        
        contentView.addSubview(colorContainer)
        let marginH: CGFloat = (view.frame.width - 80 - 6 * 23) / 5 + 23 // (view.frame.width - 22 - 19 - 19 - 20 - 6 * 23) / 5 + 23
        for (index, color) in globalColors.enumerated() {
            let colorView = UIControl(frame: CGRect(x: 19 + CGFloat(index % 6) * marginH, y: index < 6 ? 10 : 51, width: 23, height: 23))
            colorView.layer.cornerRadius = 8
            colorView.clipsToBounds = true
            colorView.backgroundColor = FCStyle.color(withHexString: color, alpha: 1)
            colorView.tag = index
            colorView.addTarget(self, action: #selector(actionClicked(sender:)), for: .touchUpInside)
            colorContainer.addSubview(colorView)
        }
        focusView.frame = CGRect(x: 19 + CGFloat(selectedColorIndex % 6) * marginH - 2.5, y: (selectedColorIndex < 6 ? 10 : 51) - 2.5, width: 28, height: 28)
        focusView.layer.cornerRadius = 10
        focusView.clipsToBounds = true
        focusView.layer.borderWidth = 1.5
        focusView.layer.borderColor = selectedColorIndex != -1 ? FCStyle.color(withHexString: globalColors[selectedColorIndex], alpha: 1).cgColor : UIColor.clear.cgColor
        colorContainer.addSubview(focusView)
        let hexLabel = UILabel(frame: CGRect(x: 21, y: 93, width: 12, height: 21))
        hexLabel.textColor = FCStyle.fcBlack
        hexLabel.font = FCStyle.subHeadline
        hexLabel.text = "#"
        colorContainer.addSubview(hexLabel)
        hexInput.textColor = FCStyle.fcBlack
        hexInput.font = FCStyle.subHeadline
        hexInput.frame = CGRect(x: 36, y: 90, width: 97, height: 25)
        hexInput.addBorder(side: .bottom, color: FCStyle.borderColor, width: 1)
        hexInput.autocorrectionType = .no
        hexInput.delegate = self
        hexInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        colorContainer.addSubview(hexInput)
        let redLabel = UILabel(frame: CGRect(x: 21, y: 127, width: 15, height: 21))
        redLabel.textColor = FCStyle.fcBlack
        redLabel.font = FCStyle.subHeadline
        redLabel.text = "R"
        colorContainer.addSubview(redLabel)
        redInput.textColor = FCStyle.fcBlack
        redInput.font = FCStyle.subHeadline
        redInput.frame = CGRect(x: 42, y: 124, width: 56, height: 25)
        redInput.addBorder(side: .bottom, color: FCStyle.borderColor, width: 1)
        redInput.keyboardType = .numberPad
        redInput.autocorrectionType = .no
        redInput.delegate = self
        redInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        colorContainer.addSubview(redInput)
        let greenLabel = UILabel(frame: CGRect(x: 31 + (view.frame.width - 100) / 3, y: 127, width: 15, height: 21))
        greenLabel.textColor = FCStyle.fcBlack
        greenLabel.font = FCStyle.subHeadline
        greenLabel.text = "G"
        colorContainer.addSubview(greenLabel)
        greenInput.textColor = FCStyle.fcBlack
        greenInput.font = FCStyle.subHeadline
        greenInput.frame = CGRect(x: 31 + (view.frame.width - 100) / 3 + 21, y: 124, width: 56, height: 25)
        greenInput.addBorder(side: .bottom, color: FCStyle.borderColor, width: 1)
        greenInput.keyboardType = .numberPad
        greenInput.autocorrectionType = .no
        greenInput.delegate = self
        greenInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        colorContainer.addSubview(greenInput)
        let blueLabel = UILabel(frame: CGRect(x: 41 + (view.frame.width - 100) * 2 / 3, y: 127, width: 15, height: 21))
        blueLabel.textColor = FCStyle.fcBlack
        blueLabel.font = FCStyle.subHeadline
        blueLabel.text = "B"
        colorContainer.addSubview(blueLabel)
        blueInput.textColor = FCStyle.fcBlack
        blueInput.font = FCStyle.subHeadline
        blueInput.frame = CGRect(x: 41 + (view.frame.width - 100) * 2 / 3 + 21, y: 124, width: 56, height: 25)
        blueInput.addBorder(side: .bottom, color: FCStyle.borderColor, width: 1)
        blueInput.keyboardType = .numberPad
        blueInput.autocorrectionType = .no
        blueInput.delegate = self
        blueInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        colorContainer.addSubview(blueInput)
        let previewLabel = UILabel()
        previewLabel.textColor = FCStyle.fcBlack
        previewLabel.font = FCStyle.subHeadline
        previewLabel.text = NSLocalizedString("Preview", comment: "")
        previewLabel.sizeToFit()
        previewLabel.frame = CGRect(x: 19 + 5 * marginH - 10 - previewLabel.frame.width, y: 92, width: previewLabel.frame.width, height: 21)
        colorContainer.addSubview(previewLabel)
        previewView.frame = CGRect(x: 19 + 5 * marginH, y: 92, width: 23, height: 23)
        previewView.layer.cornerRadius = 8
        previewView.clipsToBounds = true
        previewView.backgroundColor = FCStyle.color(withHexString: selectedColor, alpha: 1)
        colorContainer.addSubview(previewView)
        reloadColor()

        let confirmBtn = UIButton()
        confirmBtn.backgroundColor = FCStyle.accent
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.clipsToBounds = true
        confirmBtn.setTitle(folderTab != nil ? NSLocalizedString("Save", comment: "") : NSLocalizedString("Create", comment: ""), for: .normal)
        confirmBtn.titleLabel?.font = FCStyle.bodyBold
        confirmBtn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            titleContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 45),
            titlePreview.widthAnchor.constraint(equalToConstant: 23),
            titlePreview.heightAnchor.constraint(equalToConstant: 23),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 335),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            nameContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            nameContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameContainer.heightAnchor.constraint(equalToConstant: 45),
            nameInput.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 19),
            nameInput.widthAnchor.constraint(equalTo: nameContainer.widthAnchor, constant: -35),
            nameInput.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
            
            colorContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            colorContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            colorContainer.topAnchor.constraint(equalTo: nameContainer.bottomAnchor, constant: 26),
            colorContainer.heightAnchor.constraint(equalToConstant: 160),
            
            confirmBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            confirmBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            confirmBtn.topAnchor.constraint(equalTo: colorContainer.bottomAnchor, constant: 28),
            confirmBtn.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
    
    override func mainViewSize() -> CGSize {
        return CGSize(width: self.maxViewWidth() - 30, height: 380)
    }
    
    @objc
    func actionClicked(sender: UIControl) {
        if sender.tag != selectedColorIndex {
            selectedColorIndex = sender.tag
            selectedColor = globalColors[selectedColorIndex]
            reloadColor()
        }
    }
    
    func reloadColor() {
        if selectedColorIndex != -1 {
            let marginH: CGFloat = (view.frame.width - 80 - 6 * 23) / 5 + 23 // (view.frame.width - 22 - 19 - 19 - 20 - 6 * 23) / 5 + 23
            focusView.frame = CGRect(x: 19 + CGFloat(selectedColorIndex % 6) * marginH - 2.5, y: (selectedColorIndex < 6 ? 10 : 51) - 2.5, width: 28, height: 28)
            focusView.layer.borderColor = FCStyle.color(withHexString: selectedColor, alpha: 1).cgColor
        } else {
            focusView.layer.borderColor = UIColor.clear.cgColor
        }
        
        titlePreview.backgroundColor = FCStyle.color(withHexString: selectedColor, alpha: 1)
        titleLabel.text = nameInput.text
        hexInput.text = selectedColor
        redInput.text = String(selectedColor[selectedColor.startIndex..<selectedColor.index(selectedColor.startIndex, offsetBy: 2)]).hexToDec()
        greenInput.text = String(selectedColor[selectedColor.index(selectedColor.startIndex, offsetBy: 2)..<selectedColor.index(selectedColor.startIndex, offsetBy: 4)]).hexToDec()
        blueInput.text = String(selectedColor[selectedColor.index(selectedColor.startIndex, offsetBy: 4)..<selectedColor.index(selectedColor.startIndex, offsetBy: 6)]).hexToDec()
        previewView.backgroundColor = FCStyle.color(withHexString: selectedColor, alpha: 1)
    }
    
    func checkColor() {
        selectedColorIndex = -1
        for (index, color) in globalColors.enumerated() {
            if color == selectedColor {
                selectedColorIndex = index
                break
            }
        }
        reloadColor()
    }
    
    @objc
    func textFieldDidChange(textField: UITextField) {
        if textField == nameInput {
            titleLabel.text = nameInput.text
        } else if textField == hexInput {
            if textField.text?.count ?? 0 == 6 {
                selectedColor = textField.text!
                checkColor()
            }
        } else {
            if textField.text?.count ?? 0 > 0  && Int(textField.text!) ?? 0 <= 255 {
                selectedColor = redInput.text!.decToHex() + greenInput.text!.decToHex() + blueInput.text!.decToHex()
                checkColor()
            }
        }
    }
    
    @objc
    func confirm() {
        var alert: UIAlertController? = nil
        if nameInput.text?.count == 0 {
            alert = UIAlertController(title: NSLocalizedString("PinNameIsEmpty", comment: ""), message: nil, preferredStyle: .alert)
        }
        if alert != nil {
            alert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: nil))
            FCApp.keyWindow.rootViewController?.present(alert!, animated: true, completion: nil)
        } else {
            if folderTab != nil {
                folderTab?.config.name = nameInput.text!
                folderTab?.config.hexColor = selectedColor
            } else {
                folderTab = FCShared.tabManager.newTab()
                folderTab?.config.name = nameInput.text!
                folderTab?.config.hexColor = selectedColor
            }
            self.navigationController?.slideController?.dismiss()
        }
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        nameContainer.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
//        colorContainer.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
//        cloudContainer.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameInput {
            return true
        }
        
        if textField == hexInput {
            if CharacterSet(charactersIn: "0123456789ABCDEFabcdef").isSuperset(of: CharacterSet(charactersIn: string)) {
                if textField.text?.count ?? 0 < 6 || string.isEmpty || range.length > 0 {
                    return true
                }
            }
            return false
        } else {
            if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
                if textField.text?.count ?? 0 < 3 || string.isEmpty || range.length > 0 {
                    return true
                }
            }
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameInput {
            return
        }
        
        if textField != hexInput {
            if textField.text?.isEmpty ?? true {
                textField.text = "0"
                textFieldDidChange(textField: textField)
            } else if Int(textField.text!) ?? 0 > 255 {
                textField.text = "255"
                textFieldDidChange(textField: textField)
            }
        } else {
            if textField.text?.count ?? 0 < 6 {
                textField.text = selectedColor
            }
        }
    }
    
}

// View extension
enum ViewBorder: String {
    case left, right, top, bottom
}

extension UIView {

    func add(border: ViewBorder, color: UIColor, width: CGFloat) {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = color.cgColor
        borderLayer.name = border.rawValue
        switch border {
        case .left:
            borderLayer.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .right:
            borderLayer.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        case .top:
            borderLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        case .bottom:
            borderLayer.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        }
        self.layer.addSublayer(borderLayer)
    }

    func remove(border: ViewBorder) {
        guard let sublayers = self.layer.sublayers else { return }
        var layerForRemove: CALayer?
        for layer in sublayers {
            if layer.name == border.rawValue {
                layerForRemove = layer
            }
        }
        if let layer = layerForRemove {
            layer.removeFromSuperlayer()
        }
    }
    
    func addBorder(side: ViewBorder, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)
        
        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
        
        
        switch side {
        case .top:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .right:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .bottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .left:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }

}

// String extension
extension String {

    func hexToDec() -> String {
        let str = self.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return String(sum)
    }
    
    func decToHex() -> String {
        let str = String(Int(self) ?? 0, radix: 16).uppercased()
        
        return str.count < 2 ? ("0" + str) : str
    }
    
}


