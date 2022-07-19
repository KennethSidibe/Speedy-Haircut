//
//  CalendarPicker.swift
//  CalendarPickerSwiftUI
//
//  Created by Kenneth Sidibe on 2022-07-15.
//

import Foundation
import SwiftUI

struct CalendarPicker: UIViewControllerRepresentable {
    @Binding var date:Date?
    let unavailableDays:[Date]
    
    func makeUIViewController(context: Context) -> CalendarPickerViewController {
        
        let currentDate = date ?? Date()
        
        let calendarPicker = CalendarPickerViewController(
            baseDate: currentDate, unavailableDays: unavailableDays) { date in
                self.date = date
            }
        
        return calendarPicker
    }
    
    func updateUIViewController(_ uiViewController: CalendarPickerViewController, context: Context) {
    }
    
}

@available(iOS 13.0, *)
struct CalendarPickerPreviewContainer:View {
    
    @State var date:Date?
    var unavailableDates: [Date] {
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        let date1 = dateFormat.date(from: "20-07-2022")
        let date2 = dateFormat.date(from: "24-07-2022")
        let date3 = dateFormat.date(from: "31-07-2022")
        let date4 = dateFormat.date(from: "14-08-2022")
        
        return [date1!, date2!, date3!, date4!]
        
    }
    
    var body: some View {
        
        CalendarPicker(date: $date, unavailableDays: unavailableDates)
        
    }
    
}

@available(iOS 13.0, *)
struct CalendarPickerPreview:PreviewProvider {
    
    static var previews: some View {
        
        CalendarPickerPreviewContainer()
        
    }
    
}
