//
//  AlertController.swift
//  CloudKeeper
//
//  Created by Олег Адамов on 08.04.16.
//  Copyright © 2016 AdamovOleg. All rights reserved.
//

import UIKit


class AOAlertSettings {
    
    static let sharedSettings = AOAlertSettings()
    
    var titleTextFont          = UIFont.systemFontOfSize(18)
    var messageTextFont        = UIFont.systemFontOfSize(14)
    var defaultActionFont      = UIFont.systemFontOfSize(16)
    var cancelActionFont       = UIFont.systemFontOfSize(16)
    var destructiveActionFont  = UIFont.systemFontOfSize(16)
    
    var backgroundColor    = UIColor.whiteColor()
    var linesColor       = UIColor(red: 0.8, green: 0.8, blue: 0.81, alpha: 1)
    var titleTextColor     = UIColor.blackColor()
    var messageTextColor    = UIColor.darkGrayColor()
    var defaultActionColor    = UIColor.blackColor()
    var destructiveActionColor = UIColor.redColor()
    var cancelActionColor      = UIColor.blueColor()
}



enum AOAlertActionStyle {
    case Default, Destructive, Cancel
}


class AOAlertAction {
    
    var textColor: UIColor?
    var font: UIFont?
    
    init(title: String, style: AOAlertActionStyle, handler: (() -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    
    // MARK: - Private
    
    private let title: String
    private let style: AOAlertActionStyle
    private let handler: (() -> Void)?
    private var completion: (() -> Void)?
    
    private func drawOnView(parentView: UIView, frame: CGRect, completion: () -> Void) {
        let textFont  = self.font      ?? self.textFontByStyle()
        let textColor = self.textColor ?? self.textColorByStyle()
        
        let button = UIButton(frame: frame)
        button.titleLabel?.font = textFont
        button.setTitleColor(textColor, forState: .Normal)
        button.setTitle(self.title, forState: .Normal)
        button.addTarget(self, action: #selector(AOAlertAction.buttonPressed), forControlEvents: .TouchUpInside)
//        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        self.completion = completion
        parentView.addSubview(button)
    }
    
    
    @objc private func buttonPressed() {
        self.handler?()
        self.completion?()
    }
    
    
    private func textColorByStyle() -> UIColor {
        switch self.style {
        case .Cancel:      return AOAlertSettings.sharedSettings.cancelActionColor
        case .Default:     return AOAlertSettings.sharedSettings.defaultActionColor
        case .Destructive: return AOAlertSettings.sharedSettings.destructiveActionColor
        }
    }
    
    
    private func textFontByStyle() ->UIFont {
        switch  self.style {
        case .Cancel:      return AOAlertSettings.sharedSettings.cancelActionFont
        case .Default:     return AOAlertSettings.sharedSettings.defaultActionFont
        case .Destructive: return AOAlertSettings.sharedSettings.destructiveActionFont
        }
    }
    
}



enum AOAlertControllerStyle {
    case Alert, ActionSheet
}


class AOAlertController: UIViewController {
    
    var actionItemHeight: CGFloat = 44
    var backgroundColor: UIColor?
    var linesColor: UIColor?
    var titleColor: UIColor?
    var titleFont: UIFont? {
        didSet {
            if titleFont == nil { print("Error: title font is nil!") }
        }
    }
    var messageColor: UIColor?
    var messageFont: UIFont? {
        didSet {
            if messageFont == nil { print("Error: message font is nil!") }
        }
    }
    var actionItemsColor = UIColor.blackColor()
    var actionItemsFont: UIFont? {
        didSet {
            if actionItemsFont == nil { print("Error: actions font is nil!") }
        }
    }

    
    init(title: String?, message: String?, style: AOAlertControllerStyle) {
        self.alertTitle = title
        self.message = message
        self.style = style
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .OverCurrentContext
    }
    
    
    func addAction(action: AOAlertAction) {
        self.actions.append(action)
    }

    
    //MARK: - Private 
    
    private let style: AOAlertControllerStyle
    private var alertTitle: String?
    private let message: String?
    private let containerWidth: CGFloat = 270
    private let contentOffset: CGFloat = 4
    private let containerMinHeight: CGFloat = 60
    private var container = UIView()
    private var actions = [AOAlertAction]()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        self.view.alpha = 0
        
        if self.alertTitle == nil && self.message == nil {
            print("No text")
            self.alertTitle = " "
        }
        
        if self.actions.count == 0 {
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(AOAlertController.didTapBackground(_:)))
//            let tapGest = UITapGestureRecognizer(target: self, action: "didTapBackground:")
            self.view.addGestureRecognizer(tapGest)
        }
        
        self.configureContainer()
    }
    
    
    @objc private func didTapBackground(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(self.view)
        if !CGRectContainsPoint(self.container.frame, location) {
            self.hideAndDismiss()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showUp()
    }
    
    
    private func configureContainer() {
//        let titleFont         !!
        
        // heights
        let titleHeight = self.prefferedLabelHeight(text: self.alertTitle, font: self.titleFont, width: self.containerWidth - 2 * self.contentOffset)
        let messageHeight = self.prefferedLabelHeight(text: self.message, font: self.messageFont, width: self.containerWidth - 2 * self.contentOffset)
        var textBoxHeight = (titleHeight == 0 ? self.contentOffset : titleHeight + 2 * self.contentOffset) + (messageHeight == 0 ? 0 : messageHeight + self.contentOffset)
        if textBoxHeight < self.containerMinHeight { textBoxHeight = self.containerMinHeight }
        let allHeight = textBoxHeight + (self.actions.count == 2 ? self.actionItemHeight : self.actionItemHeight * CGFloat(self.actions.count))
        
        //  white rounded rectangle
        let cFrame = CGRect(x: round((UIScreen.mainScreen().bounds.width - self.containerWidth)/2), y: round((UIScreen.mainScreen().bounds.height - allHeight)/2), width: self.containerWidth, height: allHeight)
        self.container = UIView(frame: cFrame)
        self.container.backgroundColor = self.backgroundColor
        self.container.layer.cornerRadius = 11
        self.container.alpha = 0
        self.container.transform = CGAffineTransformMakeScale(0.5, 0.5)
        self.container.clipsToBounds = true
        self.view.addSubview(self.container)
        
        //  text box
        let titleYOffset = messageHeight == 0 ? (textBoxHeight - titleHeight)/2 : (textBoxHeight - titleHeight - messageHeight - self.contentOffset)/2
        let titleFrame = CGRect(x: self.contentOffset, y: titleYOffset, width: self.containerWidth - 2 * self.contentOffset, height: titleHeight)
        if let titleLabel = self.labelInFrame(titleFrame, text: alertTitle, font: titleFont, textColor: self.titleColor) {
            
            self.container.addSubview(titleLabel)
        }
        
        let messageYOffset = titleHeight == 0 ? (textBoxHeight - messageHeight)/2 : (titleYOffset + titleHeight + self.contentOffset)
        let messageFrame = CGRect(x: self.contentOffset, y: messageYOffset, width: self.containerWidth - 2 * self.contentOffset, height: messageHeight)
        if let messageLabel = self.labelInFrame(messageFrame, text: message, font: messageFont, textColor: self.messageColor) {
            self.container.addSubview(messageLabel)
        }
        
        //  line under text box
        if self.actions.count > 0 {
            let hLine = UIView(frame: CGRect(x: 0, y: textBoxHeight, width: containerWidth, height: 0.5))
            hLine.backgroundColor = self.linesColor
            self.container.addSubview(hLine)
        }
        
        //  vertival line
        if self.actions.count == 2 {
            let vLine = UIView(frame: CGRect(x: self.containerWidth/2 - 0.5, y: textBoxHeight, width: 0.5, height: allHeight - textBoxHeight))
            vLine.backgroundColor = self.linesColor
            self.container.addSubview(vLine)
            
        }
        
        //  horizontal lines
        if self.actions.count > 2 {
            for i in 1..<self.actions.count {
                let lFrame = CGRect(x: 0, y: textBoxHeight + CGFloat(i) * actionItemHeight, width: containerWidth, height: 0.5)
                let line = UIView(frame: lFrame)
                line.backgroundColor = self.linesColor
                self.container.addSubview(line)
            }
        }
        
        //  actions
        if self.actions.count == 2 {
            for i in 0..<self.actions.count {
                let frame = CGRect(x: contentOffset + CGFloat(i) * containerWidth * 0.5, y: textBoxHeight + contentOffset, width: containerWidth * 0.5 - 2 * contentOffset, height: actionItemHeight - 2 * contentOffset)
                let action = self.actions[i]
                action.drawOnView(container, frame: frame, font: defaultActionsFont, color: defaultActionItemColor, completion: { [weak self] in
                    self?.hideAndDismiss()
                })
            }
        } else {
            for i in 0..<self.actions.count {
                let frame = CGRect(x: contentOffset, y: textBoxHeight + CGFloat(i) * actionItemHeight + contentOffset, width: containerWidth - 2 * contentOffset, height: actionItemHeight - 2 * contentOffset)
                let action = self.actions[i]
                action.drawOnView(container, frame: frame, font: defaultActionsFont, color: defaultActionItemColor, completion: { [weak self] in
                    self?.hideAndDismiss()
                })
            }
        }
        
    }
    
    
    private func showUp() {
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { [weak self] in
            self?.view.alpha = 1
            }, completion: nil)
        UIView.animateWithDuration(0.4, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .CurveEaseInOut, animations: {
            self.container.alpha = 1
            self.container.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    
    private func hideAndDismiss() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .CurveEaseInOut, animations: {
            self.container.alpha = 0
            self.container.transform = CGAffineTransformMakeScale(0.5, 0.5)
            }, completion: nil)
        UIView.animateWithDuration(0.2, delay: 0.2, options: .CurveEaseInOut, animations: {
            self.view.alpha = 0
        }) { [weak self]_ in
                self?.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    
    private func prefferedLabelHeight(text text: String?, font: UIFont?, width: CGFloat) -> CGFloat {
        guard let t = text else { return 0 }
        guard let f = font else { return 0 }
        if t.isEmpty { return 0 }
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = f
        label.text = t
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    private func labelInFrame(frame: CGRect, text: String?, font: UIFont?, textColor: UIColor) -> UILabel? {
        guard let f = font else { return nil }
        guard let t = text else { return nil }
        if frame.size.height == 0 { return nil }
        
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.textColor = textColor
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.textAlignment = .Center
        label.font = f
        label.text = t
        return label
    }
    
}
