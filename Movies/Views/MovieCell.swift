//
//  MovieCell.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import UIKit
import SDWebImage

typealias EventClosure<T> = (T) -> ()

class MovieCell: UICollectionViewCell {

    static let identifier = "MovieCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var favoriteChanged: EventClosure<Bool>?
    
    func config(title: String, imageURL: String?, isFavorite: Bool) {
        titleLabel.text = title
        if let imageURL {
            imageView.sd_setImage(with: URL(string: imageURL))
        }
        favoriteButton.isSelected = isFavorite
    }
    
    @IBAction func favoriteAction(sender: UIButton) {
        favoriteChanged?(!sender.isSelected)
    }
}
