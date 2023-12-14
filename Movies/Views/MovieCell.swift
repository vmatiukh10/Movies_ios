//
//  MovieCell.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import UIKit

class MovieCell: UICollectionViewCell {

    static let identifier = "MovieCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    func config(title: String) {
        titleLabel.text = title
    }
}
