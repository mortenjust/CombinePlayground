//
//  CompanyPublisher.swift
//  CombinePlayground
//
//  Created by Morten Just on 4/7/22.
//

import Foundation
import Combine

/// based on https://stackoverflow.com/a/62160035/247277

class CompanyPublisher : Publisher {
    
    /// Really cool way to have the types of the publisher defined only once, as we need to pass them around quite a bit. Actually, it's not just "a way" - it's required.

    public typealias Output = String
    public typealias Failure = Error
    
    struct NoCompaniesError : Error {
        
    }
    
    /// Mocking a database here
    let companiesMock = ["Googz", "Macrashaft", "Boombatown", "mickmack", "Crappabble", "Masterbonka", "Rhinestone"]
    
    
    /// Called when a new subscriber starts. The `where` stuff is just to make sure we get the right kind of subscriber, so it can handle the errors and values safely
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, String == S.Input {
        let subject = PassthroughSubject<Output, Failure>()
        subject.subscribe(subscriber)
        startStreamingCompaniesRecursively(subject: subject)
    }
    
    /// We are ready to stream some results, errors or finishes
    private func startStreamingCompaniesRecursively(at index : Int = 0, subject: PassthroughSubject<Output, Failure>) {
        
        guard companiesMock.indices.contains(index) else {
            
            // Send ------> FAIL
            subject.send(completion: .failure(NoCompaniesError()))
            return
            
        }
        
        let randomDelay : Double  = .random(in: 1...3)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            
            // Send ------>  VALUE
            subject.send(self.companiesMock[index] + " delay: \(randomDelay)")
            
            
            let nextIndex = index + 1
            if self.companiesMock.indices.contains(nextIndex) {
                
                self.startStreamingCompaniesRecursively(at: index + 1, subject: subject)
                // Process the next
            } else {
                
                // Send ------> FINISH
                subject.send(completion: .finished)
            }
            
            
        }
    }
    
    
}
