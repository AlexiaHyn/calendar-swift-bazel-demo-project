//
//  File.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/18.
//

import Foundation
import CoreLocation

public class DataManager {
    public init() {
    }
    // Completion block work asynchronously
    public func pullData(url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard
                    let data = data else {
                    print("Error: No Response")
                    completion(nil)
                    return
                }
                
                // for debug
    //                if let JSONString = String(data: data, encoding: String.Encoding.utf8){
    //                    print(JSONString)
    //                }
                completion(data)
            }
        }
        task.resume()
    }
    
    // decode JSON data
    public func decodeJSON<T: Decodable>(data: Data?) -> T? {
        if let data = data {
            do {
                let decodeData = try JSONDecoder().decode(T.self, from: data)
                return decodeData
            } catch {
                print("Failed to decode JSON")
                return nil
            }
        }
        return nil
    }
}
