//
//  AgendaViewList.swift
//  CalendarAgenda
//
//  Created by Alexia Huang on 2024/12/4.
//

import SwiftUI
import CalendarCalendar
import CommonTools

public struct AgendaViewList: View {
    @ObservedObject var calendarModel: CalendarModel = CalendarModel()
    @Binding var selectedDate: Date
    @Binding var scrollOnTap: Bool
    @State var currDisplayDays: [Date] = []
    @State var scrolling: Bool = false
    @State var currScrollId: Date = CalendarProps.startOfDay(date: Date.now)
    @State var prevScrollOffset: CGFloat = 0.0
    @State var scrollViewHeight: CGFloat = 500
    @State var scrollTotalHeight: CGFloat = 1200
    
    public init(selectedDate: Binding<Date>, scrollOnTap: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._scrollOnTap = scrollOnTap
    }
    
    public var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                ForEach(currDisplayDays, id: \.self) { day in
                    Text("\(CommonFormatter.dateFormat(style: "medium").string(from: day))")
                        .id(day)
                        .frame(height: 40)
                        .onAppear {
                            if !scrolling {
                                currScrollId = day
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                            Color.clear
                                    .preference(key: ViewOffsetKey.self, value: geometry.frame(in:.global).minY
                                )
                            }
                        )
                }
            }
            .listStyle(.plain)
            .scrollDisabled(scrolling)
            .coordinateSpace(name: "scroll")
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            scrollViewHeight = geometry.size.height
                            print("scrollViewHeight: \(scrollViewHeight)")
                        }
                }
            )
            .onPreferenceChange(ViewOffsetKey.self) { currentOffset in
                print(currentOffset)
//                if currentOffset < 0 && !scrolling {
//                    scrolling = true
//                    currScrollId = calendarModel.minDay
//                    calendarModel.loadDates(date: calendarModel.minDay)
//                    DispatchQueue.main.async {
//                        scrollProxy.scrollTo(currScrollId, anchor: .top)
//                        scrolling = false
//                    }
//                } else if currentOffset + scrollViewHeight > scrollTotalHeight && !scrolling {
//                    scrolling = true
//                    currScrollId = calendarModel.maxDay
//                    calendarModel.loadDates(date: calendarModel.maxDay)
//                    DispatchQueue.main.async {
//                        scrollProxy.scrollTo(currScrollId, anchor: .bottom)
//                        scrolling = false
//                    }
//                }
                prevScrollOffset = currentOffset
            }
            .onAppear {
                calendarModel.loadDates(date: Date.now)
                currDisplayDays = calendarModel.calendarDisplayDays()
                scrollTotalHeight = 40 * CGFloat(calendarModel.displayDays)
                scrolling = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollProxy.scrollTo(calendarModel.curDay, anchor: .top)
                    scrolling = false
                }
            }
            .onChange(of: calendarModel.minDay) { newDate in
                currDisplayDays = calendarModel.calendarDisplayDays()
                scrollTotalHeight = 40 * CGFloat(calendarModel.displayDays)
            }
            .onChange(of: selectedDate) { newDate in
                if scrollOnTap {
                    if newDate < calendarModel.minDay || newDate > calendarModel.maxDay {
                        calendarModel.loadDates(date: newDate)
                        currDisplayDays = calendarModel.calendarDisplayDays()
                    }
                    scrolling = true
                    currScrollId = newDate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation{
                            scrollProxy.scrollTo(newDate, anchor: .top)
                        }
                        scrolling = false
                    }
                }
            }
        }
    }
}

private struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
