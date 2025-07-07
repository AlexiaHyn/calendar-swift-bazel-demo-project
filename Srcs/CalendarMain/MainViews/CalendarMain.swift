//
//  CalendarView.swift
//  CalendarContentView
//
//  Created by Alexia Huang on 2024/11/12.
//

import SwiftUI

public struct CalendarMain: View {
    public init() {
        
    }
    public var body: some View {
        TabView {
            MailContentView()
                .tabItem{
                    Label("Mail", systemImage: "envelope")
                }
            CalendarContentView()
                .tabItem{
                    Label("Calendar", systemImage: "calendar")
                }
        }
    }
}
