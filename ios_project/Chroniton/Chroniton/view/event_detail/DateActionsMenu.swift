//
//  DateActionsMenu.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit

protocol DateActionsMenuDelegate: AnimatedMenuDelegate {
    func dateActionsMenuChoseCalendar(_ sender: DateActionsMenu)
    func dateActionsMenuChoseToday(_ sender: DateActionsMenu)
    func dateActionsMenuChoseClear(_ sender: DateActionsMenu)
    func dateActionsMenuChose1Week(_ sender: DateActionsMenu)
    func dateActionsMenuChose1Month(_ sender: DateActionsMenu)
    func dateActionsMenuChose3Months(_ sender: DateActionsMenu)
    func dateActionsMenuChose6Months(_ sender: DateActionsMenu)
    func dateActionsMenuChose1Year(_ sender: DateActionsMenu)
    func menuOpening(_ sender: DateActionsMenu)
    func menuClosing(_ sender: DateActionsMenu)
}
extension DateActionsMenuDelegate {
    // Default implementation (making methods "optional")
    func menuOpening(_ sender: DateActionsMenu) { }
    func menuClosing(_ sender: DateActionsMenu) { }
}


class DateActionsMenu: AnimatedMenu {

    private let dismissOnSelection = true
    
    private var _buttonsList: [UIButton] = []
    private var _buttonCentersList: [CGPoint] = []
   
    weak var delegate: DateActionsMenuDelegate?

    // Users set this to help with decisions in delegate callbacks
    var userData: Any?
    
    
    class func suggestedSize() -> CGSize {
        return UIImage(named: "circle")?.size ?? CGSize.zero
    }


    func configure(delegate: DateActionsMenuDelegate,
                   menuButtonImage: UIImage,
                   widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint,
                   userData: Any?)
    {
        self.delegate = delegate
        self.userData = userData
        
        let underlayImage = UIImage(named: "circle")!

        let openSize = DateActionsMenu.suggestedSize()
        let closedSize = self.bounds.size

        let menuButtonCenterClosed = CGPoint(
            x: closedSize.width/2,
            y: closedSize.height/2)
        let menuButtonCenterOpen = CGPoint(
            x: openSize.width/2,
            y: openSize.height/2)

        super.configure(menuButtonImage: menuButtonImage, underlayImage: underlayImage,
                        closedSize: closedSize, openSize: openSize,
                        closedButtonCenter: menuButtonCenterClosed, openButtonCenter: menuButtonCenterOpen,
                        widthConstraint: widthConstraint, heightConstraint: heightConstraint)
        
        
        _buttonsList = [
            _createButton(with: UIImage(named: "icon_calendar"), selector: #selector(self.actionCalendar(_:))),
            _createButton(with: UIImage(named: "icon_today"), selector: #selector(self.actionToday(_:))),
            _createButton(with: UIImage(named: "icon_clear"), selector: #selector(self.actionClear(_:))),
            _createButton(with: UIImage(named: "icon_1week"), selector: #selector(self.action1Week(_:))),
            _createButton(with: UIImage(named: "icon_1months"), selector: #selector(self.action1Month(_:))),
            _createButton(with: UIImage(named: "icon_3months"), selector: #selector(self.action3Months(_:))),
            _createButton(with: UIImage(named: "icon_6months"), selector: #selector(self.action6Months(_:))),
            _createButton(with: UIImage(named: "icon_1year"), selector: #selector(self.action1Year(_:)))
        ]
        
        // x/y offset for the 45-degree items
        let S:CGFloat = 65
        // x/y offset for straight up/down left/right items
        let radius:CGFloat = 90
        
        // Note that images are different sizes, so offsets are manually determined
        // and adjusted for visual weighting rather than equal mathematical grid
        let calendar = CGPoint(x: menuButtonCenterOpen.x - S - 5, y: menuButtonCenterOpen.y - S + 5)
        let today = CGPoint(x: menuButtonCenterOpen.x, y: menuButtonCenterOpen.y - radius - 8)
        let x = CGPoint(x: menuButtonCenterOpen.x + S + 5, y: menuButtonCenterOpen.y - S + 5)
        let week = CGPoint(x: menuButtonCenterOpen.x - radius, y: menuButtonCenterOpen.y - 5)
        let month = CGPoint(x: menuButtonCenterOpen.x - S, y: menuButtonCenterOpen.y + S - 15)
        let month3 = CGPoint(x: menuButtonCenterOpen.x + 0, y: menuButtonCenterOpen.y + radius + 8)
        let month6 = CGPoint(x: menuButtonCenterOpen.x + S, y: menuButtonCenterOpen.y + S - 15)
        let year = CGPoint(x: menuButtonCenterOpen.x + radius, y: menuButtonCenterOpen.y - 5)
        
        _buttonCentersList = [ calendar, today, x, week, month, month3, month6, year ]
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
    func actionCalendar(_ sender: Any?) {
        delegate?.dateActionsMenuChoseCalendar(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func actionToday(_ sender: Any?) {
        delegate?.dateActionsMenuChoseToday(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func actionClear(_ sender: Any?) {
        delegate?.dateActionsMenuChoseClear(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func action1Week(_ sender: Any?) {
        delegate?.dateActionsMenuChose1Week(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func action1Month(_ sender: Any?) {
        delegate?.dateActionsMenuChose1Month(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func action3Months(_ sender: Any?) {
        delegate?.dateActionsMenuChose3Months(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func action6Months(_ sender: Any?) {
        delegate?.dateActionsMenuChose6Months(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    @objc
    func action1Year(_ sender: Any?) {
        delegate?.dateActionsMenuChose1Year(self)
        if dismissOnSelection { self.hideMenu() }
    }
    
    
    // MARK: - Notifications from superclass
    
    
    override func menuClosing() {
        delegate?.menuClosing(self)
    }
    
    override func menuOpening() {
        delegate?.menuOpening(self)
    }

}
