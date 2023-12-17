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
    private var cellConfigurator: UICollectionView.CellRegistration<MovieCell, Movie>!
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Movie.ID> = UICollectionViewDiffableDataSource(collectionView: collectionView) {
        [weak self] collectionView, indexPath, identifier -> MovieCell in
        guard let self else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        }
        let movie = self.viewModel.itemsToDisplay[indexPath.row]
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellConfigurator, for: indexPath, item: movie)
        
        return cell
    }
    
    let viewModel = MoviesViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        cellConfigurator = UICollectionView.CellRegistration<MovieCell, Movie>(cellNib: UINib(nibName: "MovieCell", bundle: nil)) { cell, indexPath, movie in
            cell.config(title: movie.title, imageURL: self.viewModel.network.imageURL(movie.poster), isFavorite: self.viewModel.isFavorite(movie: movie))
            cell.contentView.clipsToBounds = true
            cell.contentView.layer.cornerRadius = 15
            cell.favoriteChanged = { [weak self] isFavorite in
                self?.viewModel.setFavorite(index: indexPath.row, isFavorite: isFavorite)
            }
        }
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        viewModel.dataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.itemsUpdated()
            }
        }
        viewModel.fetchMovies()
    }
    
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let groupSize = {
            if UIDevice.current.isLandscape {
                return NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.75))
            } else {
                return NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.75))
            }
        }()
        let itemSize = {
            if UIDevice.current.isLandscape {
                return NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalWidth(0.25 * 1.5))
            } else {
                return NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.75))
            }
        }()
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize:  groupSize, subitems: [item])
        group.contentInsets = .zero
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func itemsUpdated() {
        guard viewModel.networkAvailable else {
            let snapshot = NSDiffableDataSourceSnapshot<Section, Movie.ID>()
            dataSource.applySnapshotUsingReloadData(snapshot)
            return
        }
        var snapshot = {
            let snapshot = dataSource.snapshot()
            guard snapshot.itemIdentifiers.isEmpty else {
                return snapshot
            }
            
            var defaultSnapshot = NSDiffableDataSourceSnapshot<Section, Movie.ID>()
            defaultSnapshot.appendSections([.main])
            return defaultSnapshot
        }()
        let allItems = viewModel.itemsToDisplay.map { $0.id }
        let newItems = allItems.filter { !snapshot.itemIdentifiers.contains($0) }
        let oldItems = snapshot.itemIdentifiers.filter { !allItems.contains($0) }
        if newItems.isEmpty {
            snapshot.deleteItems(oldItems)
            snapshot.reloadItems(allItems)
        } else {
            snapshot.appendItems(newItems, toSection: .main)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    @IBAction func segmentedChanged(sender: UISegmentedControl) {
        showFavorites(sender.selectedSegmentIndex == 1)
    }
    
    private func showFavorites(_ isFavorites: Bool) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.applySnapshotUsingReloadData(snapshot)
        viewModel.isShowFavorites = isFavorites
    }
}

extension MoviesViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !viewModel.isShowFavorites, !viewModel.isFetching, (scrollView.contentOffset.y + scrollView.bounds.height) > scrollView.contentSize.height - 200 {
            viewModel.loadMore()
        }
    }
}

extension UIDevice {
    var isLandscape: Bool {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight: return true
        default: return false
        }
    }
}
