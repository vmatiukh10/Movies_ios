//
//  MoviesViewModel.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import Foundation

class MoviesViewModel {
    
    var items: [Movie] = [] {
        didSet {
            dataUpdated?()
        }
    }
    
    var dataUpdated: (()->())?
    
    let network = Network()

    func fetchMovies() {
        Task {
            let result = await network.loadMovies()
            switch result {
            case .success(let items):
                self.items = items
            case .failure(let error):
                print(error)
            }
        }
    }
}
