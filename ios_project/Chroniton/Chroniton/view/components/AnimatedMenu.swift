//
//  AnimatedMenu.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


@objc protocol AnimatedMenuDelegate {
    @objc optional func menuOpening(_ sender: Any)
    @objc optional func menuClosing(_ sender: Any)
}


class AnimatedMenu: UIView {

    public var menuIsUp = false
    
    private var originalMenuButtonImage: UIImage?
    
    private var menuButton: UIButton!
    private var underlayImageView: UIImageView!
    
    private var closedSize: CGSize = CGSize.zero
    private var openSize: CGSize = CGSize.zero
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    // Coordinates are from upper left, but button needs to remain in bottom right. Will need to know both locations.
    private var menuButtonCenterOpen:   CGPoint = CGPoint.zero
    private var menuButtonCenterClosed: CGPoint = CGPoint.zero

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // Replacement for below init() function
    func configure(menuButtonImage: UIImage, underlayImage: UIImage,
                   closedSize: CGSize, openSize: CGSize,
                   closedButtonCenter: CGPoint, openButtonCenter: CGPoint,
                   widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint)
    {
        self.backgroundColor = UIColor.clear  // Non-clear in storyboard for visibility during design
        //self.backgroundColor = UIColor.blue

        self.closedSize = closedSize
        self.openSize   = openSize
        
        self.widthConstraint = widthConstraint
        self.heightConstraint = heightConstraint
        
        underlayImageView = UIImageView(image: underlayImage)
        underlayImageView.isUserInteractionEnabled = true // Capture and block touches

        menuButton = UIButton(type: .custom)
        menuButton.contentMode = .scaleAspectFit
        menuButton.setImage(menuButtonImage, for: .normal)
        menuButton.addTarget(self, action: #selector(self._toggleMenu(_:)), for: .touchUpInside)

        // Current frame already sized down to this button's size, so put at (0,0)
        menuButton.frame = CGRect(
            x: max((self.bounds.width - menuButtonImage.size.width) / 2, 0),
            y: max((self.bounds.height - menuButtonImage.size.height) / 2, 0),
            width: self.bounds.width,
            height: self.bounds.height
        )
        addSubview(menuButton)

        // The two alternate locations for button in overall frame
        self.menuButtonCenterClosed = closedButtonCenter
        self.menuButtonCenterOpen = openButtonCenter
        
        originalMenuButtonImage = menuButtonImage
        
        menuIsUp = false
    }
    
    
    func toggleMenu() {
        _toggleMenu(nil)
    }
    
    @objc
    func _toggleMenu(_ sender: Any?) {
        if menuIsUp {
            hideMenu()
        } else {
            showMenu()
        }
    }
    
    func showMenu() {
        if menuIsUp {
            return
        }
        menuIsUp = true
        
        _animateOut()
    }
    
    func hideMenu() {
        if !menuIsUp {
            return
        }
        menuIsUp = false
        
        _animateIn()
    }

    
    // MARK: - Private / Internal
    
    let ANIMATION_TIME_OUT = 0.2
    let ANIMATION_TIME_IN  = 0.3

    func _animateOut() {
        menuOpening()
        
        // Move activator button to where it needs to be
        menuButton.setImage(UIImage(named: "icon_blank"), for: .normal)
        menuButton.center = self.menuButtonCenterOpen
        
        // Move background image view to start animating from new button center
        if let imgView = underlayImageView {
            
            // Size image view to point in middle of menu button waiting to expand:
            imgView.frame = CGRect(x: menuButton.center.x, y: menuButton.center.y, width: 0, height: 0)
            
            // Add underlay image first, so it's on the bottom
            addSubview(imgView)
            
            // Now bring menu button on top of that
            bringSubviewToFront(menuButton)
            
            // Finally, since we're about to expand out to cover more area
            // we need to make sure we're the top-view over that area
            superview?.bringSubviewToFront(self)
        }
        
        let buttons = buttonList()
        let centers = buttonCentersList()
        
        // Make all buttons start at menu center point
        for btn: UIButton in buttons {
            btn.center = menuButton.center
            btn.alpha = 0.0
        }
        
        // Alter constraints to have width/height constants with expanded values
        self.heightConstraint?.constant = self.openSize.height
        self.widthConstraint?.constant = self.openSize.width
        self.layoutIfNeeded()

        UIView.animate(withDuration: ANIMATION_TIME_OUT, animations: {
            
            for i in 0..<buttons.count {
                let btn = buttons[i]
                self.addSubview(btn)
                btn.center = centers[i]
                
                btn.alpha = 1.0
            }
            
            let newFrame = CGRect(x: 0, y: 0, width: self.openSize.width, height: self.openSize.height)
            self.underlayImageView.frame = newFrame

        }, completion: { (ignored) in

        })
    }
    
    
    func _animateIn() {
        menuClosing()
        
        let buttons = buttonList()
        UIView.animate(withDuration: ANIMATION_TIME_IN, animations: {
            
            for i in 0..<buttons.count {
                let btn = buttons[i]
                btn.center = self.menuButton.center
                btn.alpha = 0.0
            }
            
            // Center background image on activation button center and make it zero size
            self.underlayImageView.frame = CGRect(x: self.menuButton.frame.origin.x + (self.menuButton.frame.size.width / 2),
                                                  y: self.menuButton.frame.origin.y + (self.menuButton.frame.size.height / 2),
                                                  width: 0, height: 0)
            
        }) { finished in
        
            // Alter constraints to have width/height constants with expanded values
            self.heightConstraint?.constant = self.closedSize.height
            self.widthConstraint?.constant = self.closedSize.width
            self.layoutIfNeeded()

            self.menuButton.center = self.menuButtonCenterClosed

            for btn: UIButton in buttons {
                btn.removeFromSuperview()
            }
            self.underlayImageView.removeFromSuperview()
            
            self.menuButton.setImage(self.originalMenuButtonImage, for: .normal)
        }
    }
    
    
    // MARK: - Subclasses must override
    
    
    func buttonList() -> [UIButton] {
        return []
    }
    
    func buttonCentersList() -> [CGPoint] {
        return []
    }
    
    // MARK: - Subclasses can implement if desired
    
    // Subclasses that care about responding to these events can override:
    
    func menuOpening() {
    }
    
    func menuClosing() {
    }
    
    
    // MARK: - Utilty for use by subclasses
    
    
    func _createButton(with image: UIImage?, selector: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        btn.setImage(image, for: .normal)
        
        return btn
    }

    
}
