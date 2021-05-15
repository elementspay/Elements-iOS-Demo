//
//  NetworkMonitorBuilder.swift
//  NetworkMonitor
//
//  Created by Marvin Zhan on 6/11/19.
//  Copyright © 2019 marvinzhan. All rights reserved.
//

import UIKit

public extension URLSessionConfiguration {

    private static var firstOccurrence = true

    static func connect() {
        guard firstOccurrence else { return }
        firstOccurrence = false
        // First let's make sure setter: URLSessionConfiguration.protocolClasses is de-duped
        // This ensures NetworkProtocol won't be added twice
        swizzleProtocolSetter()
        // Now, let's make sure NetworkProtocol is always included in the default configuration(s)
        // Adding it twice won't be an issue anymore, because we've de-duped the setter
        swizzleDefault()
    }

    private static func swizzleProtocolSetter() {
        let instance = URLSessionConfiguration.default

        let origSelector = #selector(setter: URLSessionConfiguration.protocolClasses)
        let newSelector = #selector(setter: URLSessionConfiguration.protocolClasses_Swizzled)

        if let aClass: AnyClass = object_getClass(instance),
            let origMethod = class_getInstanceMethod(aClass, origSelector),
            let newMethod = class_getInstanceMethod(aClass, newSelector) {
            method_exchangeImplementations(origMethod, newMethod)
        }
    }

    @objc
    private var protocolClasses_Swizzled: [AnyClass]? {
        get {
            return self.protocolClasses_Swizzled
        }
        set {
            guard let newTypes = newValue else { self.protocolClasses_Swizzled = nil; return }
            var types = [AnyClass]()
            // de-dup
            for newType in newTypes {
                if !types.contains(where: { (existingType) -> Bool in
                    existingType == newType
                }) {
                    types.append(newType)
                }
            }
            self.protocolClasses_Swizzled = types
        }
    }

    private static func swizzleDefault() {
        let origSelector = #selector(getter: URLSessionConfiguration.default)
        let newSelector = #selector(getter: URLSessionConfiguration.default_swizzled)

        if let aClass: AnyClass = object_getClass(self),
            let origMethod = class_getClassMethod(aClass, origSelector),
            let newMethod = class_getClassMethod(aClass, newSelector) {

            method_exchangeImplementations(origMethod, newMethod)
        }
    }

    @objc
    private class var default_swizzled: URLSessionConfiguration {
        get {
            let config = URLSessionConfiguration.default_swizzled
            // Core Part of init
            config.protocolClasses?.insert(NetworkProtocol.self, at: 0)
            return config
        }
    }
}
