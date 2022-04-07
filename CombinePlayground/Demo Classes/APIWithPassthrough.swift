//
//  APIWithPassthrough.swift
//  CombinePlayground
//
//  Created by Morten Just on 4/7/22.
//

import Foundation
import Combine

class APIWithPassthrough {
    var publisher = PassthroughSubject<String, Error>()
    let companiesMock = ["Googz", "Macrashaft", "Boombatown", "mickmack", "Crappabble", "Masterbonka", "Rhinestone"]
//    let companiesMock = [String]() /// Triggers NoCompaniesError

    
    struct NoCompaniesError : Error {
        
    }
    
    func start() {
        print("Startin")
        streamCompany()
    }
    
    /// Recursive function simulating a slow API
    private func streamCompany(index: Int = 0) {
        
        /// If this index is not available, it means the array is empty
        guard companiesMock.indices.contains(index) else {
            publisher.send(completion: .failure(NoCompaniesError()))
            return
        }
        
        
        /// Now delay the next send to simulate latency. It works with + 0, but not without jumping cycle on the queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.publisher.send(self.companiesMock[index])
                        
            let nextIndex = index + 1
            
            // Is the next index available?
            if self.companiesMock.indices.contains(nextIndex) {
                self.streamCompany(index: nextIndex)
            } else {
                // if it isn't, then we're done
                self.publisher.send(completion: .finished)
            }
        }
    }
}
