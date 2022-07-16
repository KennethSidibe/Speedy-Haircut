import UIKit
import SwiftUI

class CalendarPickerViewController: UIViewController {
    
    // MARK: Views
    private lazy var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    private let calendar = Calendar(identifier: .gregorian)
    
    private lazy var collectionView:UICollectionView = {
        
        //    The layout manager for our collection
        let layout = UICollectionViewFlowLayout()
        
        //    The line and item spacing
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
        
    }()
    
    private lazy var headerView = CalendarPickerHeaderView { [weak self] in
        
        guard let self = self else { return }
        
        self.dismiss(animated: true)
        
    }
    
    private lazy var footerView = CalendarPickerFooterView(
        didTapLastMonthCompletionHandler: { [weak self] in
            
            guard let self = self else { return }
            
            self.baseDate = self.calendar.date(
                byAdding: .month,
                value: -1,
                to: self.baseDate
            ) ?? self.baseDate
            
        },
        didTapNextMonthCompletionHandler: { [weak self] in
            
            guard let self = self else { return }
            
            self.baseDate = self.calendar.date(
                byAdding: .month,
                value: 1,
                to: self.baseDate
            ) ?? self.baseDate
            
        })
    
    // MARK: Calendar Data Values
    private let selectedDate: Date
    
    private var baseDate: Date {
        didSet {
            days = generateDaysInMonth(for: baseDate)
            collectionView.reloadData()
            headerView.baseDate = baseDate
        }
    }
    
    private lazy var days:[Day] = generateDaysInMonth(for: baseDate)
    
    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    
    private let selectedDateChanged: ((Date) -> Void)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    private let unavailableDays:[Date]
    
    // MARK: Initializers
    init(baseDate: Date, unavailableDays:[Date], selectedDateChanged: @escaping ((Date) -> Void)) {
        
        self.unavailableDays = unavailableDays
        
        self.selectedDate = baseDate
        //      This takes a function that is responsible for handling the date provided when the user selects a date. It acts as the delegate
        //      It is called inside the UICollectionFlowDelegate methods didSelectItemAt
        self.selectedDateChanged = selectedDateChanged
        self.baseDate = baseDate
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        definesPresentationContext = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        view.addSubview(dimmedBackgroundView)
        view.addSubview(collectionView)
        view.addSubview(headerView)
        view.addSubview(footerView)
        
        //    constraint for dimmedBackground view
        var constraints = [
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        //    constraints for collection view
        constraints.append(contentsOf: [
            collectionView.leadingAnchor.constraint(
                equalTo: view.readableContentGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.readableContentGuide.trailingAnchor),
            
            collectionView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: 10),
            collectionView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 0.5)
        ])
        
        //    Constrains for header and footer view
        constraints.append(contentsOf: [
            headerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 85),
            
            footerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        NSLayoutConstraint.activate(constraints)
        
        collectionView.register(
            CalendarDateCollectionViewCell.self,
            forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        headerView.baseDate = baseDate
        
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
}

//MARK: - Day generation
private extension CalendarPickerViewController {
    
    func monthMetadata(for baseDate:Date) throws -> MonthMetadata {
        
        //    Self explanatory
        guard let numberOfDaysInMonth = calendar.range(
            of: .day,
            in: .month,
            for: baseDate)?.count,
              
                //    Self explanatory
              let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month],
                                              from: baseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }
        
        //    return the first day of the week as a number. Eg: if the first day is Saturday it will return 6
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        //    Create the metadata of a month, ie: nb day, the first day Date, and the first day Int
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
        
    }
    
    func generateDaysInMonth(for baseDate:Date) -> [Day] {
        
        //    We create the metadata of the month with the current date
        guard let metadata = try? monthMetadata(for: baseDate) else {
            fatalError("An error occurred when generating the metadata for \(baseDate)")
        }
        
        //    we get the data of the metadata in separate variables
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        /*    We loop through all the days of the month. the range is from 1...(numberOfDays + offset)
         
         (numberOfDays + offset) will add the extra days missing from the first row of the calendar
         If the first day of the month is a friday that means there are 6 days from the previous month missing, so we will add them when generating the days
         
         */
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                
                //        this check which day should be greyed out from the current month
                //        if the offset is equal to 6 (friday) that means that 5 days should be greyed out from the firstRow
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                
                //        This is the offset for the day that should be created. If the days is withinTheDisplayedMonth days, we substract the day (Int) from the offset.
                
                //        For example if the day is 4 and the first day of the month was 6 we will get - 2 and since the firstDayOfTheMonth is 6 by adding -2 to the firstDayOfTheMonth we get 4
                
                //        If the day is not within the displayed month.
                
                //        For example, for the 1 day of this loop, which is not in the displayedMonth. the offset will be -(6 (friday) - 1) = - 5.
                
                //        If you add the day offset to the firstday of month which is the first (1) you get the 26th date
                
                
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                return generateDay(
                    offset: dayOffset,
                    for: firstDayOfMonth,
                    isWithinDisplayedMonth: isWithinDisplayedMonth)
            }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
        
    }
    
    func generateDay(
        offset dayOffset:Int,
        for baseDate:Date,
        isWithinDisplayedMonth:Bool
    ) -> Day {
        
        //    You generate the day by adding an offset to get all the days for each row
        //    for example to get the last day (monday/friday/saturday) of the previous month add - 1 to the first day of the curent month
        let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: baseDate) ?? baseDate
        
        let aYearAgo = calendar.date(
            byAdding: .year,
            value: 1,
            to: Date()) ?? Date()
        
        //      We make it false right at init
        let isDayAvailable:Bool =
        !(date.isSunday()) &&
        !(self.unavailableDays.contains(date))
        
        let isDayReservable:Bool = date.isItNextYearDate()
        && date.isDateAfterYesterday()
        
        return Day(
            date: date,
            number: dateFormatter.string(from: date),
            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
            isWithinDisplayedMonth: isWithinDisplayedMonth,
            isDayAvailable:isDayAvailable,
            isDayReservable:isDayReservable
        )
        
        
    }
    
    func generateStartOfNextMonth(using firstDayOfDisplayedMonth:Date) -> [Day] {
        
        // self explanatory
        guard
            let lastDayInMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth)
        else {
            return []
        }
        
        //    this return the number of days that should be added to the last row of the current month to complete the calendar for the current month
        //    if the first day of the week is a friday (6) that means to complete the last row we need to add 6 days at the end of the calendar
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        
        print(additionalDays)
        
        guard additionalDays > 0 else {
            return []
        }
        
        let days:[Day] = (1...additionalDays)
            .map { day in
                generateDay(
                    offset: day,
                    for: lastDayInMonth,
                    isWithinDisplayedMonth: false)
            }
        
        return days
        
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
    
}


//MARK: - UICollectionViewDataSource
extension CalendarPickerViewController: UICollectionViewDataSource {
    
    //  The number of items per section ie: the number of days to display in this current month
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }
    
    //  What to do with each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let day = days[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier,
            for: indexPath) as! CalendarDateCollectionViewCell
        
        cell.day = day
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        let day = days[indexPath.row]
        
        return day.isDayAvailable  && day.isDayReservable
        
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
        dismiss(animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
    
}

//MARK: - Date Extension

private extension Date {
    
    func isItNextYearDate() -> Bool {
        
        let calendar = Calendar(identifier: .gregorian)
        
        if let aYearAgo = calendar.date(
            byAdding: .year,
            value: 1,
            to: Date()) {
            
            return self < aYearAgo
            
        }
        else {
            return true
        }
        
    }
    
    func isDateAfterYesterday() -> Bool {
        
        let calendar = Calendar(identifier: .gregorian)
        
        if let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: Date()) {
            
            return self > yesterday
            
        }
        else {
            return true
        }
        
    }
    
}
