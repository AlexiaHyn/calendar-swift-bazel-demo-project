//
//  CalendarView.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/5.
//

import SwiftUI
import CommonTools

class HostingCalendarCell: UICollectionViewCell { // just to hold hosting controller
    var host: UIHostingController<AnyView>?
}

// MARK: CalendarController
struct CalendarController: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var collectionViewHeight: CollectionViewHeightStatus
    @State private var prevSelectedDate: Date?
    
    @Binding var scrollOnTap: Bool
    @Binding var scrollOnAgendaDrag: Bool
    @State var scrollOnCalendarDrag: Bool = false
    @State var startLoadingData: Bool = false
    
    init(selectedDate: Binding<Date>, scrollOnTap: Binding<Bool>, scrollOnDragging: Binding<Bool>, collectionViewHeight: Binding<CollectionViewHeightStatus>) {
        self._selectedDate = selectedDate
        self._scrollOnTap = scrollOnTap
        self._scrollOnAgendaDrag = scrollOnDragging
        self._collectionViewHeight = collectionViewHeight
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        // Define layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cellWidth = UIScreen.main.bounds.width / 7
        layout.itemSize = CGSize(width: cellWidth, height: 50)
        layout.sectionInset = .zero
        
        // Define collection view
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false // hide scrollbar
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        view.register(HostingCalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        
        context.coordinator.collectionView = view
        return view
    }
    
    func makeCoordinator() -> CalendarCoordinator {
        return CalendarCoordinator(selectedDate: $selectedDate, scrollOnTap: $scrollOnTap, startLoadingData: $startLoadingData, collectionViewHeight: $collectionViewHeight)
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        if (prevSelectedDate != selectedDate && !startLoadingData) {
            DispatchQueue.main.async {
                context.coordinator.scrollToSelectedDateOnTap(uiView, positionDate: selectedDate)
                prevSelectedDate = selectedDate
            }
        }
    }
}

// MARK: CalendarCoordinator
final class CalendarCoordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    public weak var collectionView: UICollectionView?
    @Binding var selectedDate: Date
    @Binding var scrollOnTap: Bool
    @Binding var startLoadingData: Bool
    @Binding var collectionViewHeight: CollectionViewHeightStatus
    @ObservedObject var calendarModel: CalendarModel = CalendarModel()
   
    init(selectedDate: Binding<Date>, scrollOnTap: Binding<Bool>, startLoadingData: Binding<Bool>, collectionViewHeight: Binding<CollectionViewHeightStatus>) {
        self._selectedDate = selectedDate
        self._scrollOnTap = scrollOnTap
        self._startLoadingData = startLoadingData
        self._collectionViewHeight = collectionViewHeight
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return CalendarProps.numDaysBetween(from: calendarModel.minDay, to:calendarModel.curSectionStartDay) - 1
        case 1:
            return CalendarProps.numDaysBetween(from: calendarModel.curSectionStartDay, to: calendarModel.curSectionEndDay)
        case 2:
            return CalendarProps.numDaysBetween(from: calendarModel.curSectionEndDay, to: calendarModel.maxDay) - 1
        default:
            return CalendarProps.numDaysBetween(from: calendarModel.curSectionStartDay, to: calendarModel.curSectionEndDay)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let currDate: Date = {
            switch (section) {
            case 0:
                return Calendar.current.date(byAdding: .day, value: row, to: calendarModel.minDay)!
            case 1:
                return Calendar.current.date(byAdding: .day, value: row, to: calendarModel.curSectionStartDay)!
            case 2:
                return Calendar.current.date(byAdding: .day, value: row + 1, to: calendarModel.curSectionEndDay)!
            default:
                return Calendar.current.date(byAdding: .day, value: row, to: calendarModel.curSectionStartDay)!
            }
        }()
        
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath)

        collectionViewCell.contentConfiguration = UIHostingConfiguration(content: {
            CalendarDay(selectedDate: $selectedDate, currDate: currDate, scrollOnTap: $scrollOnTap)
        })
        
        return collectionViewCell
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !startLoadingData {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.bounds.size.height
            if offsetY < 0 { // this bound ensure the data load is triggered by user scrolling
                startLoadingData = true
                if let collectionView = collectionView {
                    DispatchQueue.main.async {
                        let currDay = self.getTopVisibleItem(collectionView)!
                        self.calendarModel.loadDates(date: self.calendarModel.minDay)
                        collectionView.reloadData()
                        self.scrollToSelectedDate(collectionView, toDate: currDay, animated: false, at: .top)
                        self.startLoadingData = false
                    }
                }
            } else if offsetY + scrollViewHeight > contentHeight {
                startLoadingData = true
                if let collectionView = collectionView {
                    DispatchQueue.main.async {
                        let currDay = self.getTopVisibleItem(collectionView)!
                        self.calendarModel.loadDates(date: self.calendarModel.maxDay)
                        collectionView.reloadData()
                        self.scrollToSelectedDate(collectionView, toDate: currDay, animated: false, at: .top)
                        self.startLoadingData = false
                    }
                }
            }
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if startLoadingData {
            startLoadingData = false
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionViewHeight = CollectionViewHeightStatus.expanded
    }
    
    // MARK: self-defined helper functions
    public func scrollToSelectedDateOnTap(_ collectionView: UICollectionView, positionDate: Date) {
        if positionDate <= calendarModel.minDay || positionDate >= calendarModel.maxDay {
            startLoadingData = true
            calendarModel.loadDates(date: positionDate)
            collectionView.reloadData()
            self.scrollToSelectedDate(collectionView, toDate: positionDate, animated: false, at: .top)
            startLoadingData = false
        } else {
            self.scrollToSelectedDate(collectionView, toDate: positionDate, at: .top)
        }
    }
    
    func scrollToSelectedDate(_ collectionView: UICollectionView, toDate date: Date, animated: Bool = true, at position: UICollectionView.ScrollPosition) {
        let indexPath = calendarModel.indexForDate(date: date)
        collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
    }
    
    func getTopVisibleItem(_ collectionView: UICollectionView) -> Date? {
        if let firstVisibleIndexPath = collectionView.indexPathsForVisibleItems.min(by: { $0.row < $1.row && $0.section < $1.section
           }) {
            let currDate = calendarModel.dateForIndex(indexPath: firstVisibleIndexPath)
            return currDate
        }
        return nil
    }
    
}
