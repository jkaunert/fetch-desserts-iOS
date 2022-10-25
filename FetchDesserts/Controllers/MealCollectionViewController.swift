import UIKit
import AsyncNet
import iDoDeclare

class MealCollectionViewController: UIViewController {
	
	var collectionView: UICollectionView!
	
	private(set) var response: Models.RecipeResponse?
	private(set) var desserts: [Models.Meal] = []
	
	internal var mealService: any MealResponseServiceable = MealsService()
	
	static let titleElementKind = "title-element-kind"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureCollectionView()
		Task(priority: .background) {
			try await loadData(category: "Dessert")
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
}

//Fetch
extension MealCollectionViewController {
	
	@MainActor func fetchRecipe(`for` mealItem: Models.Meal) async throws  -> Models.Recipe {
		do {
			let recipe = try await mealService.getMealDetails(mealId: mealItem.id).recipes.first!
			return recipe
		}
		catch {
			showModal(title: "Error", message: NetworkError.decode.localizedDescription)
			throw error
		}
	}
	
	func fetchData(category: String) async throws -> Models.MealResponse {
		do {
			return try await mealService.getMeals(categoryName: category)
		}
		catch let error as NSError {
			throw error
		}
	}
	
	@MainActor func loadData(category: String) async throws {
		do {
			let response = try await fetchData(category: category)
			let desserts = response.meals
			self.desserts = desserts.sorted {$0.name < $1.name}
			
			self.collectionView.reloadData()
		}
		catch let error as NetworkError {
			
			self.showModal(title: "Error", message: error.message())
			throw error
		}
	}
	
	@MainActor fileprivate func showModal(title: String, message: String) {
		
		self.present(
			UIAlertController {
				$0.title = title
				$0.message = message
				$0.addAction(
					UIAlertAction(
						title: "Ok",
						style: .default,
						handler: nil)
				)
			},
			animated: true)
	}
}

//Compositional Layout
//FIXME: -
extension MealCollectionViewController {
	fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
		let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			
			//"peeking" 3rd item
			let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ? 0.425 : 0.85)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth), heightDimension: .absolute(250))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			
			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .continuous
			section.interGroupSpacing = 20
			section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
			
			let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
			
			let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: titleSize,
				elementKind: MealCollectionViewController.titleElementKind,
				alignment: .top)
			section.boundarySupplementaryItems = [titleSupplementary]
			return section
		}
		
		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.interSectionSpacing = 20
		
		let layout = UICollectionViewCompositionalLayout(
			sectionProvider: sectionProvider, configuration: config)
		return layout
	}
}
// Configuration API
extension MealCollectionViewController {
	func configureCollectionView() {
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
		
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		collectionView.backgroundColor = .systemBackground
		
		collectionView.register(cell: AsyncImageCell.self)
		
		collectionView.register(header: TitleLabelSupplementaryView.self)
		
		view.addSubview(collectionView)
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
}

// MARK: - UICollectionView Delegate
extension MealCollectionViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let dessert = desserts[indexPath.item]
		
		
		Task(priority: .background) { @MainActor in
			let recipe: Models.Recipe = try! await fetchRecipe(for: dessert)
			//			print(recipe)
			let image = await returnImage(imageUrl: recipe.imageURL)
			
			self.present(
				RecipeScrollViewController {
					$0.viewModel = recipe
					$0.image = image
				},
				animated: true
			)
		}
		
		collectionView.deselectItem(at: indexPath, animated: true)
		
	}
	fileprivate func returnImage(imageUrl: String) async -> UIImage {
		return try! await ImageService.shared.fetchImage(from: imageUrl)
	}
}

// MARK: - UICollectionView DataSource
extension MealCollectionViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Models.MealCategories.allCases.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.desserts.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeue(for: indexPath) as AsyncImageCell
		
		cell.configure(
			with: desserts[indexPath.item]
				.name,
			imageUrl: (desserts[indexPath.item].imageURL)
		)
		return cell
	}
	
	//FIXME: -
	private func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> TitleLabelSupplementaryView {
		
		let header = collectionView.dequeue(for: indexPath, kind: kind) as TitleLabelSupplementaryView
		
		header.configure(with: "Dessert")
		
		return header
	}
}

// UIKit Previews
import SwiftUI
struct MealCollectionViewController_Previews: PreviewProvider {
	static var previews: some View {
		PreviewViewController(for: MealCollectionViewController())
			.environment(\.colorScheme, .dark)
			.edgesIgnoringSafeArea(.all)
	}
}

extension UICollectionReusableView: SupplementaryViewDequeueable {}
