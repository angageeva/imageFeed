import UIKit

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Properties

    var image: UIImage! {
        didSet {
            guard isViewLoaded, let image else { return }
    
            setImage(image: image)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var scrollView: UIScrollView!

    // constants for ZoomScale
    private let minimumZoomScale = 0.1
    private let maximumZoomScale = 1.25

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale

        guard let image else { return }
        
        setImage(image: image)
    }
    
    // MARK: - UIActions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }

        let shared = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(shared, animated: true, completion: nil)
    }
    
    // MARK: delegate methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    // MARK: private methods
    
    // function for rescaling and centering Image in SingleImageView
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size

        let hScale = visibleRectSize.width/imageSize.width
        let vScale = visibleRectSize.height/imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale,vScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2

        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }

    private func setImage(image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size

        rescaleAndCenterImageInScrollView(image: image)
    }
}
