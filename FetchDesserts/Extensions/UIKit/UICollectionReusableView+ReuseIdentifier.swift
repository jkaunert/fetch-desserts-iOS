import UIKit

extension UICollectionReusableView {
	static var reuseIdentifier: String {
		return String(describing: Self.self)
	}
}

