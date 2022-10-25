import UIKit

extension UICollectionView {
	
	func register<Cell>(cell: Cell.Type) where Cell: UICollectionViewCell {
		register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
	}
	
	func register<Header>(header: Header.Type) where Header: UICollectionReusableView {
		register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Header.reuseIdentifier)
	}
	
}

