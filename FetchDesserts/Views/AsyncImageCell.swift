import UIKit
import AsyncNet
import iDoDeclare

final class AsyncImageCell: CollectionCellDequeueable {
	
	let spacing = CGFloat(10)
	
	lazy var imageView = UIImageView {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.layer.borderColor = UIColor.black.cgColor
		$0.layer.borderWidth = 1
		$0.layer.cornerRadius = 4
		$0.backgroundColor = .systemGroupedBackground
	}
	
	lazy var titleLabel = UILabel {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.preferredFont(forTextStyle: .caption1)
		$0.adjustsFontForContentSizeCategory = true
		
	}
	
	lazy var categoryLabel = UILabel {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = UIFont.preferredFont(forTextStyle: .caption2)
		$0.adjustsFontForContentSizeCategory = true
		$0.textColor = .placeholderText
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		constrainViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension AsyncImageCell {
	func configure(with title: String, imageUrl: String) {
		
		titleLabel.text = title
		categoryLabel.text = "Dessert"
		Task {
			imageView.image = await returnImage(imageUrl: imageUrl)
		}
	}
	
	fileprivate func returnImage(imageUrl: String) async -> UIImage {
		return try! await ImageService.shared.fetchImage(from: imageUrl)
	}
	
	fileprivate func constrainViews() {
		
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(categoryLabel)
		
		NSLayoutConstraint.activate([
			// ImageView Contraints
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			
			// Title Label Constraints
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			
			// Category Label Constraints
			categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
			categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
		
	}
}

