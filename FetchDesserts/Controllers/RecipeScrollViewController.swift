import UIKit
import iDoDeclare

final class RecipeScrollViewController: UIViewController {
	var viewModel: Model.Recipe!
	var image: UIImage!

	let imageHeight: CGFloat = 300
	let textFieldHeight: CGFloat = 40
	let stackViewPadding: CGFloat = 20
	
	lazy var scrollView = UIScrollView {
		$0.frame = .zero
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = .systemBackground
		$0.alwaysBounceVertical = true
		$0.delaysContentTouches = false
		$0.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
		$0.delegate = self
		$0.contentInsetAdjustmentBehavior = .never // don't shift down by safe area
	}
	
	lazy var contentContainer = UIView {
		
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = .systemBackground
	}
	
	lazy var contentVStack = `VStack` { [unowned self] in
		var views: [UIView] = [
			body,
			`Spacer`()
		]
		
		return views
	}
		.with {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.spacing = stackViewPadding
			$0.isLayoutMarginsRelativeArrangement = true
			$0.directionalLayoutMargins = .init(
				top: stackViewPadding,
				leading: stackViewPadding,
				bottom: stackViewPadding,
				trailing: stackViewPadding
			)
		}
	
	lazy var headerImage = UIImageView {
		$0.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: imageHeight))
		$0.image = self.image
		$0.contentMode = .scaleAspectFill
		$0.clipsToBounds = true
	}
	
	lazy var headerLabel = UILabel {
		$0.text = viewModel.name
	}
		.withTitleStyle
	
	lazy var ingredientsList = `VStack`(alignment: .fill, spacing: 10) { [unowned self] in
		
		var views: [UIView] = []
		
		for ingredient in viewModel.ingredients {
			let ingredientLabel = `HStack`(alignment: .fill ,spacing: 10) { [unowned self] in
				[
					
					UILabel {
						$0.text = ingredient.measure
					}.withPropertyValueStyle
						.withBox
						.withYellowHighlight
						.spacer,
					
					
					UILabel {
						$0.text = ingredient.name
						$0.textAlignment = .right
					}
						.withPropertyValueStyle,
					`Spacer`(),
				]
			}
			views.append(ingredientLabel)
		}
		return views
	}
	
	lazy var recipeInstructions = UILabel {
		$0.text = String(viewModel.steps.joined(separator: "\r\n\n"))
		
	}.withParagraphStyle
	
	lazy var body = `VStack`(spacing: 10) { [unowned self] in
		[
			headerLabel,
			ingredientsList,
			`Spacer`(),
			recipeInstructions,
			`Spacer`(),
		]
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
	}
	
	fileprivate func setupViews() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentContainer)
		contentContainer.addSubview(contentVStack)
		view.addSubview(headerImage)
		
		scrollView.pin(to: view)
		contentContainer.pin(to: scrollView)
		body.pin(
			to: contentContainer, insets: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
		)
		
		contentContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
	}
}

extension RecipeScrollViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let height = -scrollView.contentOffset.y
		if height > imageHeight {
			// stretch it
			headerImage.frame.size.height = height
		}
		else {
			// push it offscreen
			headerImage.frame.origin.y = height - imageHeight
		}
	}
}

// MARK: - View Modifiers
fileprivate extension UILabel {
	
	var withPropertyValueStyle: UILabel {
		with {
			$0.textColor = .systemGray
			$0.font = .preferredFont(forTextStyle: .body)
		}
	}
	
	var withParagraphStyle: UILabel {
		with {
			$0.textColor = .label
			$0.numberOfLines = 0
			$0.font = .preferredFont(
				forTextStyle: .footnote
			)
		}
	}
}

fileprivate extension UIView {
	private var withBoxStyle: UIView {
		with {
			$0.backgroundColor = .systemGray
			$0.layer.cornerRadius = 5
		}
	}
	
	var withBox: UIView {
		UIView {
			$0.addSubview(self)
			self.pin(to: $0,
					 insets: UIEdgeInsets(
						top: 2,
						left: 5,
						bottom: 2,
						right: 5
					 )
			)
		}
		.withBoxStyle
	}
}

//MARK: PreviewView for UIKit
import SwiftUI
struct RecipeScrollViewController_Previews: PreviewProvider {
	static var previews: some View {
		PreviewViewController(for: RecipeScrollViewController {
			$0.viewModel = Model.Recipe().previewsRecipe
		})
		.environment(\.colorScheme, .dark)
		.edgesIgnoringSafeArea(.all)
	}
}
