//
//  CatImagesVC.swift
//  SeeCats
//
//  Created by Soren Inis Ngo on 13/04/2026.
//

import UIKit
import Toaster
import KRProgressHUD
import PhotosUI

class CatImagesVC: UITableViewController {
  private var _catImages: [SCImage] = []
  private let _refreshControl = UIRefreshControl()
  private var _currentPage = 0
  private var _isPaginationLoading = false
  private var _canLoadMore = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _setupViews()
    _refreshCatImagesData()
  }
  
  private func _setupViews() {
    _refreshControl.attributedTitle = NSAttributedString(string: "Loading meows...")
    _refreshControl.addTarget(self, action: #selector(_refreshCatImagesData), for: .valueChanged)
    
    tableView.prefetchDataSource = self
    
    tableView.refreshControl = _refreshControl
  }
  
  @objc private func _refreshCatImagesData() {
    _currentPage = 0
    
    Task {
      do {
        var params = SCImage.QueryParams.defaultSearchParams()
        params.page = _currentPage
        
        _catImages = try await SCImage.search(WithParams: params)
        tableView.reloadData()
      } catch {
        _ = Toast(text: error.localizedDescription).show()
      }
      _refreshControl.endRefreshing()
    }
  }
  
  private func _loadMoreData() {
    Task {
      _isPaginationLoading = true
      
      do {
        var params = SCImage.QueryParams.defaultSearchParams()
        params.page = _currentPage + 1
        
        let newCatImages = try await SCImage.search(WithParams: params)
        _currentPage += 1
        _catImages.append(contentsOf: newCatImages)
        tableView.reloadData()
        
        if newCatImages.count == 0 {
          _canLoadMore = false
        }
      } catch {
        _ = Toast(text: error.localizedDescription).show()
      }
      
      _isPaginationLoading = false
    }
  }
  
  @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    _presentPicker()
  }
  
  private func _presentPicker() {
    var config = PHPickerConfiguration()
    config.filter = .images
    config.selectionLimit = 1
    
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    self.present(picker, animated: true)
  }
}

// MARK: - TableView

extension CatImagesVC {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return _catImages.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CatImageCell.kCellId) as! CatImageCell
    
    let data = _catImages[indexPath.row]
    cell.fill(withData: data)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let rowWidth = tableView.frame.width - (8 * 2)
    let imageWidth = CGFloat(_catImages[indexPath.row].width!)
    let imageHeight = CGFloat(_catImages[indexPath.row].height!)
    
    let rowHeight = (imageHeight / imageWidth) * rowWidth + 8
    
    return rowHeight
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let id = _catImages[indexPath.row].id!
      
      Task {
        KRProgressHUD.show()
        do {
          try await SCImage.delete(withId: id)
          tableView.beginUpdates()
          
          _catImages.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .fade)
          
          tableView.endUpdates()
        } catch {
          _ = Toast(text: error.localizedDescription).show()
        }
        KRProgressHUD.dismiss()
      }
    }
  }
}

// MARK: - PHPickerViewControllerDelegate

extension CatImagesVC: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    
    guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
    
    provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
      if let selectedImage = image as? UIImage {
        let imageData = selectedImage.jpegData(compressionQuality: 1)!
        Task {
          KRProgressHUD.show()
          do {
            let newCatImage = try await SCImage.upload(withData: imageData)
            print("Just uploaded:", newCatImage.id!)
            self?._catImages.append(newCatImage)
            self?.tableView.reloadData()
          } catch {
            _ = Toast(text: error.localizedDescription).show()
          }
          KRProgressHUD.dismiss()
        }
      }
    }
  }
}

// MARK: - UITableViewDataSourcePrefetching

extension CatImagesVC: UITableViewDataSourcePrefetching {
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      if indexPath.row >= _catImages.count - 1 && !_isPaginationLoading && _canLoadMore {
        _loadMoreData()
        break
      }
    }
  }
}
