//
//  CategoryListCell
//  Copyright © 2021 Driftwood Studio. All rights reserved.
//

import UIKit


class CategoryListCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    public var normalBackgroundImg: UIImage? = nil
    public var selectedBackgroundImg: UIImage? = nil
    
    // What to do when Edit button is tapped
    private var onEditClosure: (()->Void)? = nil
    
    func configure(for category: CategoryListDataItem, onEdit: @escaping ()->Void ) {
        
        self.title.text = category.name
        
        // Store block to perform if edit button is used
        self.onEditClosure = onEdit
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            backgroundImageView.image = selectedBackgroundImg
        }
        else {
            backgroundImageView.image = normalBackgroundImg
        }
    }

    @IBAction func invokeCategoryEdit(_ sender: Any) {
        onEditClosure?()
    }
    
    
    // UITableView edit mode:
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
//        do {
//            // indent mode for table and superclass has already been set,
//            // and by default they adjust frame of custom UI contents to remain
//            // in fixed position. Have to re-establish left edge reference so that
//            // content follows the cell's left edge in/out.
//
//            let leftEdge: CGFloat = 25
//
//            var frame = title.frame
//            frame.origin.x = leftEdge
//            title.frame = frame
//        }
    }
        
}
