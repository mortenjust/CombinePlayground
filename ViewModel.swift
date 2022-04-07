//
//  ViewModel.swift
//  CombinePlayground
//
//  Created by Morten Just on 4/7/22.
//

import Foundation
import Combine

class ViewModel : ObservableObject {
    var bag = Set<AnyCancellable>()
    
    /// For tryPassthrough
    var apiWithPassthrough : APIWithPassthrough?
    
    /// For tryPublisher
    var companyPublisher : CompanyPublisher?
    
    
    init() {
//     tryFuture()
//        tryPassthrough()
//        tryPublisher()
        tryMultipleSubscribers()
//        trySharedSubscribers()
    }
    
    
    
    /// Multicasting
    /// ----------
    /// Shared? Well, that means that `receive` is called only once. That is, when we call connect.
    /// How can you see that? The results come in EXACTLY the same time.
    ///
    func trySharedSubscribers() {
        companyPublisher = CompanyPublisher()
        
        let multicaster = companyPublisher?.multicast({
            PassthroughSubject()
        })
        
        /// connect the receiver to the multicaster. This starts the shit.
        multicaster?.connect().store(in: &bag)
        
        multicaster?.sink(receiveCompletion: { completion in
            print("multi1: completion", completion)
        }, receiveValue: { company in
            print("multi1: received value", company)
        }).store(in: &bag)
            
        
        multicaster?.sink(receiveCompletion: { completion in
            print("multi2: completion", completion)
        }, receiveValue: { company in
            print("multi2: received value", company)
        }).store(in: &bag)
        
        
    }
    
    /// Multiple non-shared subscribers
    /// -------------------------
    /// Non-shared? Well, that means that `receive` is called each time we connect a new subscriber.
    /// How can you see that? The results come in at random times, and almost never at exactly the same time
    func tryMultipleSubscribers() {
        companyPublisher = CompanyPublisher()
        
        /// This works, *but* it triggers calling the API twice. One each time.
        
        companyPublisher?.sink(receiveCompletion: { completion in
            print("pub1: complete")
        }, receiveValue: { company in
            print("pub1: received value", company)
        }).store(in: &bag)
        
        companyPublisher?.sink(receiveCompletion: { completion in
            print("pub2: complete")
        }, receiveValue: { company in
            print("pub2: received value", company)
        }).store(in: &bag)
        
    }
    
    
    
    
    /// Custom publisher
    /// --------------
    /// This is the biggest hammer with the most flexibility. You most likely don't need this, and a passthrough subject is more than enough in most cases. A future is enough if you only do a single value.
    
    
    func tryPublisher() {
        companyPublisher = CompanyPublisher()
        
        companyPublisher?
            .sink(receiveCompletion: { completion in
            print("Publisher completed:", completion)
        }, receiveValue: { company in
            print("Publisher received:", company)
        })
            .store(in: &bag)
    }
    
    
    
    /// Passthrough Subject. A super light-weight and simple publisher you can easily build into any class.
    /// -----
    /// A publisher that can publish as many subjects as it wants, and then finally tell its subscriber that it is done.
    /// How's it different from a publisher? It's less flexible, like having something happening on new subscriptions, and we're `sink`ing on a `publisher` rather than on the class itself. The result is a `publisher` on a well-known class, resulting in the same interface as Apple has added to their pre-Combine era classes—and also a few new ones.
    
    /// API used with tryPassthrough

    
    func tryPassthrough() {
        /// Simulating a server
        /// let companiesServerside = ["Googz", "Macrashaft", "Boombatown", "mickmack", "Crappabble", "Masterbonka", "Rhinestone"]
        
        self.apiWithPassthrough = APIWithPassthrough()
        apiWithPassthrough?.start()
        
        apiWithPassthrough?.publisher.sink { completion in
            print("Passthrough completed!", completion)
        } receiveValue: { company in
            print("Passthrough: received:", company)
        }.store(in: &bag)
    }
    
    
    
    
    
    /// Future
    /// -----
    /// A single, one-off publisher that can trigger anytime in the future
    
    
    /// A combine future with error handling
    func tryFuture() {
        
        
        struct CompanyError : Error {
            let message: String
        }
        
        func fetchCompanies() -> Future<[String], CompanyError> {
            return Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let companiesMock = ["Googz", "Macrashaft", "Boombatown", "mickmack", "Crappabble", "Masterbonka", "Rhinestone"]
                    
                    promise(.success(companiesMock))
                    
                    // or throw an error .....
//                    promise(.failure(CompanyError(message: "We just couldn't find any, man!")))
                }
            }
        }
        
        fetchCompanies()
            .receive(on: DispatchQueue.main)
            .sink { result in
            switch result {
            case .failure(let error):
                print("Resulted in an error", error.message)
            case .finished:
                print("No more values coming in. A promise is just once.")
            }
        } receiveValue: { companies in
            print("we got companies", companies)
        }.store(in: &bag)

        
        
        
    }
    
    
}
