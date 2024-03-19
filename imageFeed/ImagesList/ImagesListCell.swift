import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientLayerView: UIView!
    
    @IBAction func likeButtonClicked(){}
    
    var gradientLayer: CAGradientLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = gradientLayerView.bounds
        gradientLayerView.clipsToBounds = true
        gradientLayerView.layer.cornerRadius = 16
        gradientLayerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
