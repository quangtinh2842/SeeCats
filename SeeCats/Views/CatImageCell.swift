//
//  CatImageCell.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 13/04/2026.
//

import UIKit
import AlamofireImage
import SkeletonView

final class CatImageCell: UITableViewCell {
  
  // MARK: - Outlets
  
  @IBOutlet weak var _vImageContainer: UIView!
  @IBOutlet weak var _imgImage: UIImageView!
  
  // MARK: - Properties
  
  static let kCellId = "CatImageCell"
  
  // MARK: - Life cycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupUI()
  }
  
  // MARK: - Public methods
  
  func fill(withData data: SCImage) {
    _imgImage.image = nil
    _vImageContainer.showAnimatedGradientSkeleton()
    _imgImage.af.setImage(withURL: URL(string: data.url!)!, imageTransition: .crossDissolve(0.5), completion: { [weak self] _ in
      self?._vImageContainer.hideSkeleton()
    })
  }
  
  // MARK: - Private methods
  
  private func setupUI() {
    _vImageContainer.isSkeletonable = true
    _vImageContainer.layer.cornerRadius = 8
    _vImageContainer.clipsToBounds = true
  }
}
