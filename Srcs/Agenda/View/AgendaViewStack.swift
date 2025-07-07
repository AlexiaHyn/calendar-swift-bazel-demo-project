//
//  AgendaViewList.swift
//  Experiment: implementation of AgendaView with LazyVStack and ScrollView
//
//  Created by Alexia Huang on 2024/12/3.
//

import SwiftUI
import CalendarCalendar
import CommonTools

public struct AgendaViewStack: View {
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
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(currDisplayDays, id: \.self) { day in
                        Text("\(CommonFormatter.dateFormat(style: "medium").string(from: day))")
                            .id(day)
                            .frame(height: 40)
                            .onAppear {
                                if !scrolling {
                                    currScrollId = day
                                }
                            }
                    }
                }
                .onAppear {
                    calendarModel.loadDates(date: Date.now)
                    currDisplayDays = calendarModel.calendarDisplayDays()
                    scrolling = true
                    DispatchQueue.main.async {
                        scrollProxy.scrollTo(calendarModel.curDay, anchor: .top)
                        scrolling = false
                    }
                }
                .onChange(of: calendarModel.minDay) { newDate in
                    currDisplayDays = calendarModel.calendarDisplayDays()
                }
                .onChange(of: selectedDate) { newDate in
                    if scrollOnTap {
                        if newDate < calendarModel.minDay || newDate > calendarModel.maxDay {
                            calendarModel.loadDates(date: newDate)
                            currDisplayDays = calendarModel.calendarDisplayDays()
                        }
                        scrolling = true
                        DispatchQueue.main.async {
                            withAnimation{
                                scrollProxy.scrollTo(newDate, anchor: .top)
                            }
                            scrolling = false
                        }
                    }
                }
                .background(GeometryReader { geometry in
                    Color.clear
                        .preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scroll")).origin.y
                        )
                        .onChange(of: geometry.size.height) { newHeight in
                            scrollTotalHeight = newHeight
                        }
                })
                .onPreferenceChange(ViewOffsetKey.self) { currentOffset in
                    if currentOffset < 0 && !scrolling {
                        scrolling = true
                        currScrollId = calendarModel.minDay
                        calendarModel.loadDates(date: calendarModel.minDay)
                        DispatchQueue.main.async {
                            scrollProxy.scrollTo(currScrollId, anchor: .top)
                            scrolling = false
                        }
                    } else if currentOffset + scrollViewHeight > scrollTotalHeight && !scrolling {
                        scrolling = true
                        currScrollId = calendarModel.maxDay
                        calendarModel.loadDates(date: calendarModel.maxDay)
                        DispatchQueue.main.async {
                            scrollProxy.scrollTo(currScrollId, anchor: .bottom)
                            scrolling = false
                        }
                    }
                    prevScrollOffset = currentOffset
                }
            }
            .coordinateSpace(name: "scroll")
            .disabled(scrolling)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            scrollViewHeight = geometry.size.height
                        }
                }
            )
        }
    }
}


private struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
