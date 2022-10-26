import UIKit
import AsyncNet
import iDoDeclare

class MealCollectionViewController: UIViewController {
	
	private(set) var response: Model.RecipeResponse?
	
	private(set) var desserts: [Model.Meal] = []
	
	private(set) var layoutEnvironment: NSCollectionLayoutEnvironment?
	
	internal var mealService: any MealResponseServiceable = MealsService()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		constrainCollectionView()
		Task(priority: .background) {
			try await loadData(category: "Dessert")
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	lazy var collectionView =  UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout()).with {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = .systemBackground
		$0.register(cell: AsyncImageCell.self)
		$0.register(header: TitleLabelSupplementaryView.self)
		$0.delegate = self
		$0.dataSource = self
	}
	
	
	lazy var group = NSCollectionLayoutGroup
		.horizontal(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(
					CGFloat(
						(layoutEnvironment?.container.effectiveContentSize.width ?? 0) > 500 ? 0.425 : 0.85)
				),
				heightDimension: .absolute(250)
			),
			subitems:
				[
					NSCollectionLayoutItem(
						layoutSize: NSCollectionLayoutSize(
							widthDimension: .fractionalWidth(1.0),
							heightDimension: .fractionalHeight(1.0)
						)
					)
				]
		)
	
	lazy var sectionProvider =
	{ [unowned self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
		return section }
	
	lazy var section = NSCollectionLayoutSection(group: group).with {
		$0.orthogonalScrollingBehavior = .continuous
		
		$0.interGroupSpacing = 20
		
		$0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
		
		$0.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44)),
			elementKind: TitleLabelSupplementaryView.reuseIdentifier,
			alignment: .top)
		]
	}
}

//Fetch
extension MealCollectionViewController {
	
	@MainActor func fetchRecipe(`for` mealItem: Model.Meal) async throws -> Model.Recipe {
		do {
			let recipe = try await mealService.getMealDetails(mealId: mealItem.id).recipes.first!
			return recipe
		}
		catch {
			showModal(title: "Error", message: NetworkError.decode.localizedDescription)
			throw error
		}
	}
	
	func fetchData(category: String) async throws -> Model.MealResponse {
		do {
			return try await mealService.getMeals(categoryName: category)
		}
		catch {
			throw NetworkError.networkError(error)
		}
	}
	
	@MainActor func loadData(category: String) async throws {
		do {
			let response = try await fetchData(category: category)
			let desserts = response.meals
			self.desserts = desserts.sorted {$0.name < $1.name}
			
			self.collectionView.reloadData()
		}
		catch {
			
			self.showModal(title: "Error", message: "\(NetworkError.decodingError(error))")
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
extension MealCollectionViewController {
	fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout(
			sectionProvider: sectionProvider, configuration: UICollectionViewCompositionalLayoutConfiguration { $0.interSectionSpacing = 20 }
		)
	}
}

//Add CollectionView + Constrain
extension MealCollectionViewController {
	
	func constrainCollectionView() {
		view.addSubview(collectionView)
		
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
			let recipe: Model.Recipe = try! await fetchRecipe(for: dessert)
			
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
	
	@MainActor func returnImage(imageUrl: String) async -> UIImage {
		do {
			let fetchedImage = try await ImageService.shared.fetchImage(from: imageUrl)
			return fetchedImage
		}
		catch {
			present(
				UIAlertController(
					title: "Error",
					message: "Error fetching image from \(imageUrl)",
					preferredStyle: .alert
				)
				.with {
					$0.addAction(
						UIAlertAction(
							title: "Dismiss",
							style: .cancel
						) { _ in }
					)
				},
				animated: true
			)
			return UIImage(named: "draw")! //default image
		}
	}
}

// MARK: - UICollectionView DataSource
extension MealCollectionViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Model.MealType.allCases.count
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

extension UICollectionReusableView: SupplementaryViewDequeueable {}

// UIKit Previews
import SwiftUI
struct MealCollectionViewController_Previews: PreviewProvider {
	static var previews: some View {
		PreviewViewController(for: MealCollectionViewController())
			.environment(\.colorScheme, .dark)
			.edgesIgnoringSafeArea(.all)
	}
}

