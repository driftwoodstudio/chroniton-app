//
//  DetailActionsMenu.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


protocol DetailActionsMenuDelegate: AnimatedMenuDelegate {
    func detailActionsMenuChoseEmail(_ sender: DetailActionsMenu)
    func detailActionsMenuChoseDelete(_ sender: DetailActionsMenu)
    func detailActionsMenuChoseInfo(_ sender: DetailActionsMenu)
    func menuOpening()
    func menuClosing()
}
extension DetailActionsMenuDelegate {
    // Default implementation (making methods "optional")
    func menuOpening() { }
    func menuClosing() { }
}


class DetailActionsMenu: AnimatedMenu {

    private var _buttonsList: [UIButton] = []
    private var _buttonCentersList: [CGPoint] = []
    
    weak var delegate: DetailActionsMenuDelegate?

    
    class func suggestedSize() -> CGSize {
        return UIImage(named: "menu_bg_quarter")!.size
    }
    

    func configure(delegate: DetailActionsMenuDelegate, menuButtonImage: UIImage,
                   widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint)
    {
        let underlayImage = UIImage(named: "menu_bg_quarter")!
        
        let openSize = DetailActionsMenu.suggestedSize()
        let closedSize = self.bounds.size
        
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
        
        _buttonsList = [_createButton(with: UIImage(named: "icon_email"), selector: #selector(self.actioneEmailButton(_:))), _createButton(with: UIImage(named: "icon_trash"), selector: #selector(self.actionDeleteButton(_:))), _createButton(with: UIImage(named: "icon_i"), selector: #selector(self.actionInfoButton(_:)))]
        
        _buttonCentersList = [ CGPoint(x: 123, y: 46), CGPoint(x: 73, y: 79), CGPoint(x: 45, y: 127) ]

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
    
    
    @objc func actioneEmailButton(_ sender: Any?) {
        delegate?.detailActionsMenuChoseEmail(self)
    }
    
    @objc func actionDeleteButton(_ sender: Any?) {
        delegate?.detailActionsMenuChoseDelete(self)
    }
    
    
    @objc func actionInfoButton(_ sender: Any?) {
        delegate?.detailActionsMenuChoseInfo(self)
    }

    
    // MARK: - Notifications from superclass
    
    
    override func menuClosing() {
        delegate?.menuClosing()
    }
    
    override func menuOpening() {
        delegate?.menuOpening()
    }

}

