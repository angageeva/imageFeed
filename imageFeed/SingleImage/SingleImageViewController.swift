import UIKit

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Properties

    var photo: Photo?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var scrollView: UIScrollView!

    // constants for ZoomScale
    private let minimumZoomScale = 0.1
    private let maximumZoomScale = 1.25

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let photo = photo else { return }

        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale

        setImage(photo: photo)
    }
    
    // MARK: - Public methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    // MARK: - UIActions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }

        let shared = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(shared, animated: true, completion: nil)
    }
    
    // MARK: private methods
    
    // function for rescaling and centering Image in SingleImageView
    private func rescaleAndCenterImageInScrollView() {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale

        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = imageView.frame.size

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

    private func setImage(photo: Photo) {
        UIBlockingProgressHUD.show()
        imageView.frame.size = photo.size

        imageView.kf.setImage(with: URL(string: photo.fullImageURL), placeholder: UIImage(named: "scribble_placeholder")) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }

            switch result {
            case .success:
                self.rescaleAndCenterImageInScrollView()
            case .failure:
                print("[SingleImageViewController -> setImage]: Error loading photo from url: \(photo.fullImageURL)")
                self.showError(photo: photo)
            }
        }
    }
    
    private func showError(photo: Photo) {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Что-то пошло не так. Попробовать ещё раз?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                self?.setImage(photo: photo)
            })
            
            present(alert, animated: true, completion: nil)
        }
}
