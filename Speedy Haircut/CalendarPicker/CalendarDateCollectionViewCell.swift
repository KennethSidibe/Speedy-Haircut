
import UIKit

class CalendarDateCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: CalendarDateCollectionViewCell.self)
    
    var day:Day? {
        
        didSet {
            
            guard let day = day else { return }
            
            // reseting the strikethrough style
            numberLabel.attributedText = nil
            
            numberLabel.text = day.number
            
            accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatuts()
            
        }
        
    }
    
    //  A red circle that appears when cell is selected
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemRed
        return view
    }()
    
    //  number of day of the month for the cell
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    //  Convert cell's date to a readable format
    private lazy var accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()
    
    //  Added to view selectionView and numberLabel
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This allows for rotations and trait collection
        // changes (e.g. entering split view on iPad) to update constraints correctly.
        // Removing old constraints allows for new ones to be created
        // regardless of the values of the old ones
        NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)
        
        let size = traitCollection.horizontalSizeClass == .compact ? min(min(frame.width, frame.height) - 10, 60) : 45
        
        //    constraint set
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            selectionBackgroundView.centerYAnchor
                .constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor
                .constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: size),
            selectionBackgroundView.heightAnchor
                .constraint(equalTo: selectionBackgroundView.widthAnchor),
            
        ])
        
        selectionBackgroundView.layer.cornerRadius = size / 2
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layoutSubviews()
    }
    
    
}

//MARK: - Appearance
private extension CalendarDateCollectionViewCell {
    
    func updateSelectionStatuts() {
        
        guard let day = day else { return }
        
        if day.isSelected && day.isDayAvailable {
            applySelectedStyle()
        }
        else if !(day.isDayReservable) {
            applyUnreservableDayStyle()
        }
        else if !(day.isDayAvailable) {
            applyUnavailableDayStyle()
        } else {
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
        
    }
    
    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight =
        UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        return isCompact && (smallWidth || widthGreaterThanHeight)
    }
    
    func applySelectedStyle() {
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil
        
        numberLabel.textColor = isSmallScreenSize ? .systemRed : .white
        selectionBackgroundView.isHidden = isSmallScreenSize
        
    }
    
    func applyUnreservableDayStyle() {
        
        numberLabel.textColor = .quaternaryLabel
        selectionBackgroundView.isHidden = true
        
    }
    
    func applyUnavailableDayStyle() {
        
        let textAttribute = NSAttributedString(
            string: numberLabel.text!,
            attributes: [.strikethroughStyle: NSUnderlineStyle.thick.rawValue]
        )
        numberLabel.attributedText = textAttribute
        
        numberLabel.textColor = .quaternaryLabel
        selectionBackgroundView.isHidden = true
        
    }
    
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"
        
        let textAttribute = NSAttributedString(
            string: numberLabel.text!,
            attributes: [:]
        )
        numberLabel.attributedText = textAttribute
        
        numberLabel.textColor = isWithinDisplayedMonth ? .label : .secondaryLabel
        selectionBackgroundView.isHidden = true
        
    }
    
}


extension Date {
    
    func isSunday() -> Bool {
        
        let calendar = Calendar(identifier: .gregorian)
        
        return calendar.component(.weekday, from: self) == 1
        
    }
    
}
