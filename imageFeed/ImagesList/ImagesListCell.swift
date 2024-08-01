import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    var gradientLayer: CAGradientLayer?

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientLayerView: UIView!
    
    weak var delegate: ImagesListCellDelegate?

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
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public methods
    
    func setIsLiked(isLiked: Bool)  {
        likeButton.setImage(UIImage(named: isLiked ? "favorites_button_on" : "favorites_button_off"), for: .normal)
    }
    
    // MARK: - Private methods
    
    private func resizeGradientLayerView() {
        gradientLayer?.frame = gradientLayerView.bounds
        gradientLayerView.clipsToBounds = true
        gradientLayerView.layer.cornerRadius = ImagesListCell.cornerRadius
        gradientLayerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
