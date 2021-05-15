//
//  TextViewConfig.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/13/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

/// Scroll position for ElementsTextView's scroll and search methods.
public enum TextViewSearchDisplayPosition {
    /// Scrolls until the rect/range/text is on top of the text view.
    case top
    /// Scrolls until the rect/range/text is in the middle of the text view.
    case middle
    /// Scrolls until the rect/range/text is at the bottom of the text view.
    case bottom
    /// Scrolls until the rect/range/text is visible with minimal movement.
    case none
}

public enum TextViewSearchDirection {
    case forward
    case backward
}
