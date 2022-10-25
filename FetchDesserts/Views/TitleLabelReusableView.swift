import UIKit
import iDoDeclare

final class TitleLabelSupplementaryView: UICollectionReusableView {
	
	let inset = CGFloat(10)
	
	lazy var label = UILabel {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.adjustsFontForContentSizeCategory = true
		$0.font = UIFont.preferredFont(forTextStyle: .title3)
		
		$0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
		$0.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset).isActive = true
		$0.topAnchor.constraint(equalTo: topAnchor, constant: inset).isActive = true
		$0.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset).isActive = true
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(label)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension TitleLabelSupplementaryView {
	
	func configure(with category: String) {
		label.text = category
	}
}
