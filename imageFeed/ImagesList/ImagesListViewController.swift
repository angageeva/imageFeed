import UIKit

class imagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    func configCell(for cell: ImagesListCell) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 250
    }

}
