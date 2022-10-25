import UIKit
protocol SupplementaryViewDequeueable {}

typealias CollectionCellDequeueable = UICollectionViewCell

typealias CollectionViewReusable = (SupplementaryViewDequeueable & UICollectionReusableView)

extension UICollectionView {
	func dequeue<Cell>(for indexPath: IndexPath) -> Cell where Cell: CollectionCellDequeueable {
		return dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
	}
	
	func dequeue<Header>(for indexPath: IndexPath, kind: String) -> Header where Header: CollectionViewReusable {
		return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseIdentifier, for: indexPath) as! Header
	}
}
