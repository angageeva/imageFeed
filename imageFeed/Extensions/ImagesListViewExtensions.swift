import UIKit

// MARK: - ImagesListViewExtensions

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.photoByIndex(index: indexPath.row) else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width

        guard imageWidth != 0 else {
            imageFeedLog.logError("Error: The width of the image is equal to zero")
            return 0
        }
        let scale = imageViewWidth / imageWidth
        let heightForRow = image.size.height * scale + imageInsets.top + imageInsets.bottom

        return heightForRow
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let photosCount = presenter?.photosCount() else { return }

        if indexPath.row + 1 == photosCount {
            presenter?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let photosCount = presenter?.photosCount() else { return 0 }
        
        return photosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            imageFeedLog.logError("Error: Unable to dequeue reusable cell")

            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter?.photoByIndex(index: indexPath.row)
        else { return }
        
        UIBlockingProgressHUD.show()
        
        presenter?.changeLike(photoId: photo.id, isLiked: photo.isLiked) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                guard let photo = presenter?.photoByIndex(index: indexPath.row) else { return }

                cell.setIsLiked(isLiked: photo.isLiked)
            case .failure:
                self.showErrorAlert()
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(action)

        present(alertController, animated: true, completion: nil)
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photosCount = presenter?.photosCount(),
              let image = presenter?.photoByIndex(index: indexPath.row),
              indexPath.row < photosCount
        else { return }
        
        guard let url = URL(string: image.thumbImageURL) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "sribble_placeholder"))
        
        cell.dateLabel.text = image.createdAt != nil ? presenter?.getFormattedDate() : ""

        let gradient = cellGradient()

        cell.gradientLayerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        cell.gradientLayerView.layer.insertSublayer(gradient, at: 0)
        cell.gradientLayer = gradient
    }

    private func cellGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let finalColor = UIColor.ypBlack.withAlphaComponent(0.2)
        let startColor = UIColor.ypBlack.withAlphaComponent(0.0)

        gradient.colors = [startColor.cgColor, finalColor.cgColor]

        return gradient
    }
}
