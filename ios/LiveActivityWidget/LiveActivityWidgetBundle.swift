//
//  LiveActivityWidgetBundle.swift
//  LiveActivityWidget
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import WidgetKit
import SwiftUI

@main
struct LiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        Co2Widget()
        if #available(iOS 16.2, *) {
            LiveActivityWidgetLiveActivity()
        }
    }
}
