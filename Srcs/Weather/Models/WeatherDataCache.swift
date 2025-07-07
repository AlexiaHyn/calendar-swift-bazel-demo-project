//
//  WeatherDataCache.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/12/3.
//

import Foundation

public class WeatherDataCache {
    typealias CacheType = NSCache<NSString, NSData>
    
    public static let shared = WeatherDataCache()
    
    private init() {}
    
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 100
        return cache
    }()
    
    func object(forKey key: String) -> Data? {
        let NSKey: NSString = key as NSString
        return cache.object(forKey: NSKey) as? Data
    }
    
    func set(object: NSData, forKey key: String) {
        let NSKey: NSString = key as NSString
        cache.setObject(object, forKey: NSKey)
    }
}
