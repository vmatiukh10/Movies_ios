//
//  MoviesViewController.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import UIKit

class MoviesViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataDource: UICollectionViewDiffableDataSource<Section, Movie.ID>!
    
    let viewModel = MoviesViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.dataUpdated = { [weak self] in
            self?.itemsUpdated()
        }
        viewModel.fetchMovies()
        configureDataSource()
        collectionView.dataSource = dataDource
    }
    
    func itemsUpdated() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Movie.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.items.map { $0.id }, toSection: .main)
        dataDource.applySnapshotUsingReloadData(snapshot)
    }
    
    private func configureDataSource() {
        // Create a cell registration that the diffable data source will use.
        let cellRegistration = UICollectionView.CellRegistration<MovieCell, Movie> { cell, indexPath, movie in
            cell.config(title: movie.title)
        }


        // Create the diffable data source and its cell provider.
        dataDource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, identifier -> MovieCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
            let movie = self.viewModel.items[indexPath.row]
            cell.config(title: movie.title)
            return cell
        }
    }
    
    @IBAction func segmentedChanged(sender: UISegmentedControl) {
        
    }
}
