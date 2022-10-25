import UIKit
import iDoDeclare

final class MainTabViewController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewControllers = [
			TabNavController.make(with: MealCollectionViewController(), title: "Fetch Desserts", imageName: "takeoutbag.and.cup.and.straw"),
			
			// TODO: Search Feature
			TabNavController.make(with: UIViewController(), title: "Search", imageName: "magnifyingglass"),
		]
	}
}

import SwiftUI
struct MainTabViewController_Previews: PreviewProvider {
	static var previews: some View {
		PreviewViewController(for: MainTabViewController())
			.environment(\.colorScheme, .dark)
			.edgesIgnoringSafeArea(.all)
	}
}

