//
//  MoviesViewModel.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import Foundation

class MoviesViewModel {
    
    let network = Network()
    
    let coreData = CoreDataManager.shared
    
    var items: [Movie] = []
    
    var favoriteItems: [Movie] {
        items.filter { movie in
            favoriteMovies.contains {
                movie.id == $0.id && $0.isFavorite
            }
        }
    }
    
    lazy var itemsToDisplay: [Movie] = {
        isShowFavorites ? favoriteItems : items
    }() {
        didSet {
            dataUpdated?()
        }
    }
    
    var isShowFavorites: Bool = false {
        didSet {
            itemsToDisplay = isShowFavorites ? favoriteItems : items
            
        }
    }
    
    private var favoriteMovies: [FavoriteMovies] {
        didSet {
            dataUpdated?()
        }
    }
    
    var currentPage = 1
    
    var totalPages = 1
    var isFetching = false
    
    var dataUpdated: (()->())?
    
    var networkAvailable: Bool = true {
        didSet {
            guard networkAvailable != oldValue else {
                return
            }
            networkAvailable ? fetchMovies() : noInternetConnection()
        }
    }
    
    init() {
        self.favoriteMovies = coreData.getFavorites()
        network.networkAvailablityChanged = { [weak self] isAvailable in
            self?.networkAvailable = isAvailable
        }
    }
    
    func noInternetConnection() {
        dataUpdated?()
    }
    
    func loadMore() {
        guard currentPage < totalPages else {
            return
        }
        currentPage += 1
        fetchMovies()
    }
    
    func fetchMovies() {
        isFetching = true
        Task {
            let result = await network.loadMovies(page: currentPage)
            switch result {
            case .success(let result):
                items.append(contentsOf: result.0)
                totalPages = result.1
                itemsUpdated()
            case .failure(let error):
                print(error)
            }
            isFetching = false
        }
    }
    
    func setFavorite(index: Int, isFavorite: Bool) {
        let item = itemsToDisplay[index]
        favoriteMovies = coreData.updateFavorite(id: item.id, isFavorite: isFavorite)
        itemsUpdated()
    }
    
    private func itemsUpdated() {
        itemsToDisplay = isShowFavorites ? favoriteItems : items
    }
    
    func isFavorite(movie: Movie) -> Bool {
        favoriteMovies.first { $0.id == movie.id }?.isFavorite ?? false
    }
}
