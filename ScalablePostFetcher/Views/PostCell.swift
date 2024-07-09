import UIKit

/// UITableViewCell subclass for displaying post data.
class PostCell: UITableViewCell {
    /// Reuse identifier for the cell.
    static let reuseIdentifier = "PostCell"
    
    /// UILabel to display the post title.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(_colorLiteralRed: 0.0, green: 70.0/255.0, blue: 139.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// UILabel to display the post body.
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Initializer for the cell.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add titleLabel and bodyLabel to the cell's content view.
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        
        // Set up constraints for titleLabel and bodyLabel.
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// Required initializer for decoding the cell (not implemented).
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the cell with a Post object.
    /// - Parameter post: The Post object to display.
    func configure(with post: Post) {
        titleLabel.text = post.title
        bodyLabel.text = post.body
    }
}
