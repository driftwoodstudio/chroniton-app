//
//  ListActionsMenu.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


protocol CategoryListActionsMenuDelegate: AnimatedMenuDelegate {
    func listActionsMenuChoseNew(_ sender: EventListActionsMenu?)
    func listActionsMenuChoseSend(_ sender: EventListActionsMenu?)
    func listActionsMenuChoseInfo(_ sender: EventListActionsMenu?)
}


class EventListActionsMenu: AnimatedMenu {
    
    weak var delegate: CategoryListActionsMenuDelegate?
    
    private var _buttonsList: [UIButton] = []
    private var _buttonCentersList: [CGPoint] = []

    
    class func suggestedSize() -> CGSize {
        return UIImage(named: "menu_bg_quarter")!.size
    }
    
    
    func configure(delegate: CategoryListActionsMenuDelegate, menuButtonImage: UIImage,
                   widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint)
    {
        let underlayImage = UIImage(named: "menu_bg_quarter")!

        let openSize = EventListActionsMenu.suggestedSize()
        let closedSize = self.bounds.size  // Note: storyboard size set to EXACTLY size of specific button image used!
        
        // The two alternate locations for button in overall frame
        let menuButtonCenterClosed = CGPoint(
            x: closedSize.width/2,
            y: closedSize.height/2)
        let menuButtonCenterOpen = CGPoint(
            x: openSize.width  - menuButtonImage.size.width/2,
            y: openSize.height - menuButtonImage.size.height/2)

        super.configure(menuButtonImage: menuButtonImage, underlayImage: underlayImage,
                        closedSize: closedSize, openSize: openSize,
                        closedButtonCenter: menuButtonCenterClosed, openButtonCenter: menuButtonCenterOpen,
                        widthConstraint: widthConstraint, heightConstraint: heightConstraint)

        self.delegate = delegate

        _buttonsList = [
            _createButton(with: UIImage(named: "icon_plus"), selector: #selector(EventListActionsMenu.actionNewButton(_:))),
            _createButton(with: UIImage(named: "icon_email"), selector: #selector(EventListActionsMenu.actionEmailButton(_:))),
            _createButton(with: UIImage(named: "icon_i"), selector: #selector(EventListActionsMenu.actionInfoButton(_:)))
        ]

        _buttonCentersList = [
            CGPoint(x: 123, y: 46),
            CGPoint(x: 73, y: 79),
            CGPoint(x: 45, y: 127)
        ]

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    // MARK: - Overrides of superclass stubs
    
    
    override func buttonList() -> [UIButton] {
        return _buttonsList
    }
    
    override func buttonCentersList() -> [CGPoint] {
        return _buttonCentersList
    }
    
    
    
    // MARK: - Button Actions
 
    
    @objc
    func actionEmailButton(_ sender: Any?) {
        delegate?.listActionsMenuChoseSend(self)
    }
    
    @objc
    func actionNewButton(_ sender: Any?) {
        delegate?.listActionsMenuChoseNew(self)
    }
    
    @objc
    func actionInfoButton(_ sender: Any?) {
        delegate?.listActionsMenuChoseInfo(self)
    }
}

