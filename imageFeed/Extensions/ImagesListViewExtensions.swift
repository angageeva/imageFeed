import UIKit

extension imagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            imageFeedLog.logError("Couldn't find the image")
            
            return 0
        }
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
}

extension imagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoNames.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            imageFeedLog.logError("Error: Unable to dequeue reusable cell")

            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension imagesListViewController {
    func getFormattedDate() -> String {
        lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }()
        
        return dateFormatter.string(from: Date())
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "\(indexPath.row)") else { return }
        cell.cellImage.image = image
        
        cell.dateLabel.text = getFormattedDate()
        
        cell.likeButton.setImage(cellFavoriteImage(index: indexPath.row), for: .normal)

        let gradient = cellGradient()
        cell.gradientLayerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        cell.gradientLayerView.layer.insertSublayer(gradient, at: 0)
        cell.gradientLayer = gradient
    }
    
    func cellFavoriteImage(index: Int) -> UIImage? {
        let isEven = index % 2 == 0
        let buttonImage = isEven ? UIImage(named: "favorites_button_on") : UIImage(named: "favorites_button_off")
        
        return buttonImage
    }
    
    func cellGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let finalColor = UIColor.ypBlack.withAlphaComponent(0.2)
        let startColor = UIColor.ypBlack.withAlphaComponent(0.0)
        gradient.colors = [startColor.cgColor, finalColor.cgColor]

        return gradient
    }
}
