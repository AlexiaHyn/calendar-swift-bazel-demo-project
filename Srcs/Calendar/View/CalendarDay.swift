//
//  CalendarDay.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/27.
//

import SwiftUI
import CommonTools

struct CalendarDay: View {
    @Binding var selectedDate: Date
    @Binding var scrollOnTap: Bool
    private var currDate: Date
    
    init(selectedDate: Binding<Date>, currDate: Date, scrollOnTap: Binding<Bool>) {
        self._selectedDate = selectedDate
        self.currDate = currDate
        self._scrollOnTap = scrollOnTap
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                if (currDate == CalendarProps.startOfMonth(for: currDate)) && (currDate != selectedDate) {
                    Text("\(CommonFormatter.dateMonthFormat(for: currDate))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Text("\(CommonFormatter.dateDayFormat(for: currDate))")
                    .foregroundStyle(
                        CalendarProps.startOfDay(date:Date.now) == currDate ?
                            .white
                        : selectedDate == currDate ?
                            .blue
                        : .gray
                    )
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
            .background(
                Circle()
                    .foregroundStyle(
                        CalendarProps.startOfDay(date:Date.now) == currDate ?
                            .blue
                        : selectedDate == currDate ?
                            .blue.opacity(0.2)
                        : .clear
                    )
                    .frame(width: 40, height: 40)
            )
            Divider()
        }
        .frame(width: UIScreen.main.bounds.width / 7)
        .background(
            CalendarProps.isMonthEven(for: currDate) ?
                .clear
            : .gray.opacity(0.07)
        )
        .onTapGesture {
            selectedDate = currDate
            scrollOnTap = true
        }
    }
}
