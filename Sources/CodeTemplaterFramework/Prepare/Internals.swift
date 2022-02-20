//
//  Internals.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 30/07/2020.
//

import Foundation

/// The overview of internal Cocoa Foundation and UIKit types
enum Internals {
    static let genericTypes = [
        "Any",
        "AnyObject"
    ]

    static let foundationTypes = [
        "AffineTransform",
        "Array",
        "Calendar",
        "CharacterSet",
        "Data",
        "Date",
        "DateComponents",
        "DateInterval",
        "Decimal",
        "Dictionary",
        "Float",
        "IndexPath",
        "IndexSet",
        "Int",
        "Locale",
        "Measurement",
        "Notification",
        "NSAffineTransform",
        "NSArray",
        "NSCalendar",
        "NSCharacterSet",
        "NSData",
        "NSDate",
        "NSDateComponents",
        "NSDateInterval",
        "NSDecimalNumber",
        "NSDictionary",
        "NSIndexPath",
        "NSIndexSet",
        "NSLocale",
        "NSMeasurement",
        "NSNotification",
        "NSNumber",
        "NSPersonNameComponents",
        "NSSet",
        "NSString",
        "NSTimeZone",
        "NSURL",
        "NSURLComponents",
        "NSURLQueryItem",
        "NSURLRequest",
        "PersonNameComponents",
        "Set",
        "String",
        "TimeZone",
        "URL",
        "URLComponents",
        "URLQueryItem",
        "URLRequest",
        "UUID"
    ]

    static let uiKitTypes = [
        "NSDirectionalEdgeInsets",
        "NSDirectionalRectEdge",
        "UIActivityIndicatorView",
        "UIAxis",
        "UIBarButtonItem",
        "UIBarButtonItemGroup",
        "UIBarItem",
        "UIBlurEffect",
        "UIButton",
        "UIColorWell",
        "UIControl",
        "UIDatePicker",
        "UIDirectionalRectEdge",
        "UIEdgeInsets",
        "UIImageView",
        "UILabel",
        "UILargeContentViewerInteraction",
        "UINavigationBar",
        "UIOffset",
        "UIPageControl",
        "UIPickerView",
        "UIProgressView",
        "UIScrollView",
        "UISearchBar",
        "UISearchTextField",
        "UISearchToken",
        "UISegmentedControl",
        "UISlider",
        "UIStackView",
        "UIStepper",
        "UISwitch",
        "UITabBar",
        "UITabBarItem",
        "UITextField",
        "UITextView",
        "UIToolbar",
        "UIVibrancyEffect",
        "UIView",
        "UIViewController",
        "UINavigationViewController",
        "UIVisualEffect",
        "UIVisualEffectView",
        "UIWebView",
        "UITableViewCell",
        "UICollectionViewCell"
    ]

    static let systemTypes: Set<String> = Set(genericTypes + foundationTypes + uiKitTypes)

    static let systemFrameworks = ["Foundation", "UIKit"]
}
