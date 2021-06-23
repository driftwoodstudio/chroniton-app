//
//  EventListCell.swift
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


class EventListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var indicatorImage: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    public var normalBackgroundImg: UIImage? = nil
    public var selectedBackgroundImg: UIImage? = nil
        
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            backgroundImageView.image = selectedBackgroundImg
        }
        else {
            backgroundImageView.image = normalBackgroundImg
        }
    }

    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        do {
            // indent mode for table and superclass has already been set,
            // and by default they adjust frame of custom UI contents to remain
            // in fixed position. Have to re-establish left edge reference so that
            // content follows the cell's left edge in/out.
            
            let leftEdge: CGFloat = 25
            
            var frame = titleLabel.frame
            frame.origin.x = leftEdge
            titleLabel.frame = frame
            
            frame = subtitleLabel.frame
            frame.origin.x = leftEdge
            subtitleLabel.frame = frame
            
            frame = indicatorImage.frame
            frame.origin.x = 0
            indicatorImage.frame = frame
        }
        
        var alpha: CGFloat
        if editing {
            alpha = 0.0
        } else {
            alpha = 1.0
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.subtitleLabel.alpha = alpha
            })
        }
        else {
            self.subtitleLabel.alpha = alpha
        }
    }
        
    
    func configureCell(toShow event: EventListDataItem) {
        // FIXME: why does adding DispatchQueue.main.async { } around this cause NO UI to appear for row ??

        let cellImage = self._determineCorrectImage(for: event)
        
        self.indicatorImage.image = cellImage
        
        self.titleLabel.text = event.title
        
        var subtitle: String
        if event.lastDate != nil {
            subtitle = DateStrHelper.toString(event.lastDate)
        } else {
            subtitle = ""
        }
        if event.lastDate != nil && event.notes != "" {
            subtitle = subtitle + (" - ")
        }
        if event.notes != "" {
            subtitle = subtitle + (event.notes ?? "")
        }
        self.subtitleLabel.text = subtitle
    }
    

    func _determineCorrectImage(for event: EventListDataItem) -> UIImage? {
        
        var cellImage: UIImage? = nil
        
        if let due = event.nextDate {
            
            var target = Date()
            
            if due.isBefore(target) {
                cellImage = UIImage(named: "list_indicator_red")
            }
            else {
                target = target.addWeeks(1)
                if due.isBefore(target) {
                    cellImage = UIImage(named: "list_indicator_yellow")
                } else {
                    cellImage = UIImage(named: "list_indicator_green")
                }
            }
        }
        
        return cellImage
    }
    

}
