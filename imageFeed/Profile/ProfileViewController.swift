import UIKit

// MARK: ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let imageView = UIImageView()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addProfileImage()
        addLabels()
        addExitButton()
    }
    
    // MARK: private methods
    
    private func addProfileImage() {
        //creating UIImage
        let avatarImage = UIImage(named: "avatar")
        
        imageView.image = avatarImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //adding subview
        view.addSubview(imageView)
        
        //adding constraints
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    private func addLabels() {
        let nameLabel = UILabel()
        let nickLabel = UILabel()
        let descriptionLabel = UILabel()
        
        addNameLabel(nameLabel: nameLabel)
        addnickLabel(nickLabel: nickLabel, nameLabel: nameLabel)
        addDescriptionLabel(descriptionLabel: descriptionLabel, nickLabel: nickLabel)
    }
    
    private func addNameLabel(nameLabel: UILabel) {
        // editing nameLabel
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    private func addnickLabel(nickLabel: UILabel, nameLabel: UILabel) {
        // editing nickLabel
        nickLabel.text = "@ekaterina_nov"
        nickLabel.font = UIFont.systemFont(ofSize: 13)
        nickLabel.textColor = .ypGray
        
        nickLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickLabel)
        
        nickLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nickLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        nickLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }

    private func addDescriptionLabel(descriptionLabel: UILabel, nickLabel: UILabel) {
        // editing descriptionLabel
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 0

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: nickLabel.bottomAnchor, constant: 8).isActive = true
    }
 
    // function for adding exit button
    private func addExitButton() {
        let button = UIButton.systemButton(
            with: UIImage(named: "exit_button")!,
            target: nil,
            action: nil
        )
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26).isActive = true
    }
}
