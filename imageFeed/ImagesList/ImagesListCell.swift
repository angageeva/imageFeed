import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    var gradientLayer: CAGradientLayer?

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientLayerView: UIView!

    static private let cornerRadius = 16.0

    override func layoutSubviews() {
        super.layoutSubviews()

        resizeGradientLayerView()
    }
    
    @IBAction func likeButtonClicked(){}
    
    private func resizeGradientLayerView() {
        gradientLayer?.frame = gradientLayerView.bounds
        gradientLayerView.clipsToBounds = true
        gradientLayerView.layer.cornerRadius = ImagesListCell.cornerRadius
        gradientLayerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
