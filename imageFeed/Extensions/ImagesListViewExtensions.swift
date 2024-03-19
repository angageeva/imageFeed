import UIKit
import os.log

extension imagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        
        let heightForRow = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return heightForRow
    }
}

extension imagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            os_log("Error: Unable to dequeue reusable cell for identifier: ImagesListCell.reuseIdentifier", log: log, type: .error)
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension imagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "\(indexPath.row)") else {
            return
        }
        cell.cellImage.image = image
        
        lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }() //todo where i have to put this?
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let isEven = indexPath.row % 2 == 0
        let buttonImage = isEven ? UIImage(named: "favorites_button_on") : UIImage(named: "favorites_button_off")
        cell.likeButton.setImage(buttonImage, for: .normal)

        //GRADIENT

        let gradient = CAGradientLayer()
        let finalColor = UIColor.ypBlack.withAlphaComponent(0.2)
        let startColor = UIColor.ypBlack.withAlphaComponent(0.0)
        
        gradient.colors = [startColor.cgColor, finalColor.cgColor]
        
        // Remove existing gradient layer before adding a new one
        cell.gradientLayerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Set gradient as the background layer of the cellImage
        cell.gradientLayerView.layer.insertSublayer(gradient, at: 0)
        
        // Save the gradient layer reference to update its frame in layoutSubviews
        cell.gradientLayer = gradient
    }
}
