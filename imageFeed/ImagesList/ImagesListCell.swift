import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    var gradientLayer: CAGradientLayer?

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientLayerView: UIView!

    static private let cornerRadius = 16.0

    // MARK: - Public methods
    
    override func layoutSubviews() {
        super.layoutSubviews()

        resizeGradientLayerView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonClicked(){}
    
    // MARK: - Private methods
    
    private func resizeGradientLayerView() {
        gradientLayer?.frame = gradientLayerView.bounds
        gradientLayerView.clipsToBounds = true
        gradientLayerView.layer.cornerRadius = ImagesListCell.cornerRadius
        gradientLayerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
