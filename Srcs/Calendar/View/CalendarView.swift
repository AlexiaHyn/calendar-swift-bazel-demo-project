//
//  CalendarView.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/26.
//

import SwiftUI
import CommonTools

public struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var scrollOnTap: Bool
    @Binding var scrollOnDragging: Bool
    @State var collectionViewHeight = CollectionViewHeightStatus.expanded
    @State private var currentSize: CGFloat = 250
    
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    let dayColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    @State private var days: [Date] = []
    
    public init(selectedDate: Binding<Date>, scrollOnTap: Binding<Bool>, scrollOnDragging: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._scrollOnTap = scrollOnTap
        self._scrollOnDragging = scrollOnDragging
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                }
            }
            .background(.white)
            Divider()
            CalendarController(selectedDate: $selectedDate, scrollOnTap: $scrollOnTap, scrollOnDragging: $scrollOnDragging, collectionViewHeight: $collectionViewHeight)
            // Important: When Using UIKit in SwiftUI, control properties like height in SwiftUI, not in UIKit
                .frame(height: currentSize)
                .animation(.easeInOut, value: currentSize)
            
            Label("", systemImage: "minus")
                .foregroundStyle(.gray)
                .font(.largeTitle)
                .padding(.bottom, 10)
                .frame(width: UIScreen.main.bounds.width, height: 20)
                .background(Color.white)
                .clipShape(PartialRoundedCornersRectangle(radius: 10, corners: [.bottomLeft, .bottomRight]))
                
        }
        .background(
            selectedDate != CalendarProps.startOfDay(date: Date.now) ?
                .gray.opacity(0.1)
            :
                .blue.opacity(0.1)
        )
        .onChange(of: collectionViewHeight) { newStatus in
            withAnimation {
                currentSize = newStatus.rawValue * 50
            }
        }
        .onChange(of: scrollOnDragging) { dragging in
            if dragging {
                collectionViewHeight = CollectionViewHeightStatus.folded
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let verticalDist = value.translation.height
                    var updateSize = max(100, currentSize + verticalDist)
                    updateSize = min(250, updateSize)
                    currentSize = updateSize
                }
                .onEnded { value in
                    let verticalDist = value.translation.height
                    if verticalDist > 0 {
                        // dragging down
                        collectionViewHeight = CollectionViewHeightStatus.expanded
                    } else {
                        // draggin up
                        collectionViewHeight = CollectionViewHeightStatus.folded
                        
                    }
                    withAnimation {
                        currentSize = collectionViewHeight.rawValue * 50
                    }
                }
        )
    }
}

struct PartialRoundedCornersRectangle: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

enum CollectionViewHeightStatus: CGFloat {
    case expanded = 5, folded = 2
}
