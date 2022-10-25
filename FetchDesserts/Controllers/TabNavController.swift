import UIKit
import iDoDeclare

final class TabNavController: UIViewController {
	
	static func make(with viewController: UIViewController, title: String, imageName: String) -> UIViewController {
		return UINavigationController(rootViewController: viewController
			.with {
			$0.view.backgroundColor = UIColor.white
			$0.navigationItem.title = title
		})
		.with {
			$0.tabBarItem.title = title
			$0.tabBarItem.image = UIImage(systemName: imageName)
			$0.navigationBar.prefersLargeTitles = true
		}
	}
}

