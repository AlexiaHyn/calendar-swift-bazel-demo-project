//
//  AgendaViewController.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/21.
//

import Foundation
import SwiftUI
import UIKit
import CalendarEvents
import CalendarWeather
import CalendarCalendar
import CoreData

class HostingCell: UITableViewCell { // just to hold hosting controller
    var host: UIHostingController<AnyView>?
}

class HostingHeader: UITableViewHeaderFooterView { // just to hold hosting
    var host: UIHostingController<AnyView>?
}

// MARK: AgendaController
public struct AgendaViewController: UIViewRepresentable {
    private let viewContext: NSManagedObjectContext
    @Binding var dayEvents: Dictionary<Date, [EventItem]>
    @Binding var selectedDate: Date
    
    @State private var prevSelectedDate: Date?
    @State var currDate: Date = Date()
    
    @Binding var scrollOnTap: Bool // changes from calendar tap
    @State var scrollOnDrag: Bool = false // update calendar data range because of user dragging action
    @Binding var userDragging: Bool // changes from agenda scrolling; record whether user is dragging

    public init(viewContext: NSManagedObjectContext, dayEvents: Binding<[Date: [EventItem]]>, selectedDate: Binding<Date>, scrollOnTap: Binding<Bool>, scrollOnDragging: Binding<Bool>) {
        self.viewContext = viewContext
        self._dayEvents = dayEvents
        self._selectedDate = selectedDate
        self._scrollOnTap = scrollOnTap
        self._userDragging = scrollOnDragging
    }

    public func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = 25
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(HostingCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(HostingHeader.self, forHeaderFooterViewReuseIdentifier: "SectionHeader")
        context.coordinator.tableView = tableView
        return tableView
    }

    public func updateUIView(_ uiView: UITableView, context: Context) {
        // case selectedDate changes
        if scrollOnTap {
            DispatchQueue.main.async {
                self.currDate = selectedDate
                self.prevSelectedDate = selectedDate
                context.coordinator.scrollToSelectedDateOnTap(uiView, positionDate: selectedDate)
            }
        }
    
        // case dayEvents changes because of scolling
        else if scrollOnDrag || userDragging {
            return
        }
        // case newEvent is created
        else {
            context.coordinator.updateNewEvent(uiView)
        }
    }

    public func makeCoordinator() -> AgendaCoordinator {
        return AgendaCoordinator(selectedDate: $selectedDate, dayEvents: $dayEvents, scrollOnTap: $scrollOnTap, scrollOnDrag: $scrollOnDrag, userDragging: $userDragging)
    }
}

// MARK: AgendaCoorinator
public final class AgendaCoordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
    public weak var tableView: UITableView?
    @ObservedObject var calendarModel: CalendarModel = CalendarModel()
    private let agendaModel: AgendaModel = AgendaModel()
    @Binding private var selectedDate: Date
    @Binding private var dayEvents: [Date: [EventItem]]
    @Binding private var scrollOnTap: Bool
    @Binding private var scrollOnDrag: Bool
    @Binding private var userDragging: Bool

    public init(selectedDate: Binding<Date>, dayEvents: Binding<[Date: [EventItem]]>, scrollOnTap: Binding<Bool>, scrollOnDrag: Binding<Bool>, userDragging: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._dayEvents = dayEvents
        self._scrollOnTap = scrollOnTap
        self._scrollOnDrag = scrollOnDrag
        self._userDragging = userDragging
    }
    
    // MARK: UITableViewDelegate: Create a header
    public func tableView(_ tableView: UITableView, viewForHeaderInSection: Int) -> UIView? {
        let currDate = agendaModel.dateForSection(section: viewForHeaderInSection, date: calendarModel.minDay)
        let tableViewHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader")
        tableViewHeader?.contentConfiguration = UIHostingConfiguration(content: {
            WeatherView(currDate: currDate)
                .frame(width: tableView.frame.width)
        })
        return tableViewHeader
    }
    
    
    // MARK: UITableViewDataSource
    // create Tableview: total number of sections
    public func numberOfSections(in: UITableView) -> Int {
        return calendarModel.displayDays
    }
    // create Tableview: number of rows in a given section
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currDate = agendaModel.dateForSection(section: section, date: calendarModel.minDay)
        let events = dayEvents[currDate, default: []]
        let rowCount = events.count
        if rowCount == 0 {
            return 1
        } else {
            return rowCount
        }
    }
    // create Tableview: the display of table cell at a given indexPath
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let rowNum = indexPath.row
        
        let currDate = agendaModel.dateForSection(section: section, date: calendarModel.minDay)
        let events = dayEvents[currDate, default: []]
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if events.count > rowNum {
            tableViewCell.contentConfiguration = UIHostingConfiguration(content: {
                EventItemView(currDate: currDate, event: events[rowNum])
            })
            tableViewCell.selectionStyle = .none
        } else {
            tableViewCell.contentConfiguration = UIHostingConfiguration(content: {
                EventItemView(currDate: currDate, event: nil)
            })
            tableViewCell.selectionStyle = .none
        }
        return tableViewCell
    }
 
    // MARK: UIScrollViewDelegate
    // Update case I - dayEvents changes because of scolling
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollOnTap && !scrollOnDrag && userDragging {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.bounds.size.height
            
            if let tableView = tableView {
                // note down the current first visible item
                let currDate = self.getTopVisibleItem(tableView)!
                selectedDate = currDate
                
                // scroll to top OR scroll to bottom
                if (offsetY < 0) || (offsetY + scrollViewHeight > contentHeight ) {
                    DispatchQueue.main.async {
                        self.scrollOnDrag = true
                        let currDate = self.getTopVisibleItem(tableView)
                        self.calendarModel.loadDates(date: currDate!)
                        tableView.reloadData()
                        self.scrollToSelectedDate(tableView, toDate: currDate!, animated: false)
                    }
                }
            }
            
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userDragging = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        if !willDecelerate {
            userDragging = false
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        userDragging = false
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollOnTap {
            scrollOnTap = false
        }
    }
    
    // MARK: self-defined helper functions
    // Update Case II - selectedDate changes: check scrollOnTap
    public func scrollToSelectedDateOnTap(_ tableView: UITableView, positionDate: Date) {
        // init case included(selectedDate is initialized to be Date())
        if scrollOnTap {
            if !(positionDate >= calendarModel.minDay && positionDate <= calendarModel.maxDay) {
                calendarModel.loadDates(date: positionDate)
                tableView.reloadData()
            }
            self.scrollToSelectedDate(tableView, toDate: positionDate)
        }
    }
    
    // Update case III - newEvent is created
    public func updateNewEvent(_ tableView: UITableView) {
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }
    
    func scrollToSelectedDate(_ tableView: UITableView, toDate date: Date, animated: Bool = true) {
        if date >= calendarModel.minDay && date <= calendarModel.maxDay {
            let sectionNum = agendaModel.sectionForDate(minDate: calendarModel.minDay, date: date)
            if sectionNum < tableView.numberOfSections {
                tableView.scrollToRow(at: IndexPath(row: 0, section: sectionNum), at: .top, animated: animated)
                if !animated && scrollOnDrag {
                    scrollOnDrag = false
                }
            }
        }
    }
    
    func getTopVisibleItem(_ tableView: UITableView) -> Date? {
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows,
        let firstVisibleIndexPath = visibleIndexPaths.first {
            let currDate = agendaModel.dateForSection(section: firstVisibleIndexPath.section, date: calendarModel.minDay)
            return currDate
        }
        return nil
    }
}
