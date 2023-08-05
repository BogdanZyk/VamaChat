//
//  SearchViewModel.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject{
    
    @Published var results: [ShortUser] = []
    @Published var query: String = ""
    @Published private(set) var viewState: SearchViewState = .loaded
    @Published var showSearchList: Bool = false
    private var cancelBag = CancelBag()
    private let userService = UserService.share
    private var fbListener = FBListener()
    
    init(){
        listenToSearch()
    }
    
    deinit{
        cancelBag.cancel()
        fbListener.cancel()
    }
    
    private func listenToSearch(){
        $query
            .dropFirst()
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] delayQuery in
                guard let self = self else {return}
                if !delayQuery.isEmpty, delayQuery.count >= 2{
                    searchUsers(delayQuery)
                }
            }
            .store(in: cancelBag)
    }
    
    
    private func searchUsers(_ query: String){
        viewState = .loading
        let searchQuery = query.first == "@" ? query : "@\(query)"
        
        let fbListenerResult = userService.findUsers(query: searchQuery.lowercased())
        
        self.fbListener.listener = fbListenerResult.listener
        
        fbListenerResult.publisher.sink {[weak self] completion in
            self?.viewState = .loaded
            switch completion{
                
            case .finished: break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] users in
            guard let self = self else {return}
            self.results = users.map({ShortUser(user: $0)})
            if results.isEmpty{
                self.viewState = .empty
            }else{
                self.viewState = .loaded
            }
        }
        .store(in: cancelBag)
        
    }
    
    func selectedUser(_ user: ShortUser){
        NSApplication.shared.endEditing()
        resetSearch()
    }
    
    
    func activateOrDeactivateSearch(_ isFocused: Bool){
        if isFocused{
            showSearchList = isFocused
        }else{
            resetSearch()
        }
    }
    
    private func resetSearch(){
        query = ""
        showSearchList = false
        results = []
        viewState = .loaded
    }
}


    
enum SearchViewState{
    case empty
    case loading
    case loaded
}


