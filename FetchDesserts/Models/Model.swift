import Foundation
import iDoDeclare

typealias IngredientName = String
typealias IngredientMeasure = String
typealias RecipeStep = String

//Namespace for Models
enum Model {
	enum MealType: String, CaseIterable {
		case desserts = "Dessert"
	}
}

extension Model {
	struct MealResponse: Decodable, Hashable, AnyWithable {
		var meals: [Meal] = []
	}
}

extension Model {
	struct Meal: Decodable, Hashable, AnyWithable {
		var id: String = ""
		var name: String = ""
		var imageURL: String = ""
	}
}

// Recipe AKA MealDetails
extension Model {
	struct RecipeResponse: Decodable, Hashable, AnyWithable {
		var recipes: [Recipe] = []
	}
}

extension Model {
	struct Recipe: Decodable, Hashable, AnyWithable {
		var id: String = ""
		var name: String = ""
		var category: String = ""
		var imageURL: String = ""
		var ingredients: [Ingredient] = []
		var steps: [RecipeStep] = []
	}
}

extension Model {
	struct Ingredient: Codable, Hashable, AnyWithable {
		
		var name: IngredientName = ""
		var measure: IngredientMeasure = ""
		var imageURL: String {
			return "https://www.themealdb.com/images/ingredients/\(name).png"
		}
	}
}

extension Model.Recipe {
	
	init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let nameContainer = try decoder.container(keyedBy: IngredientNameCodingKeys.self)
		let measureContainer = try decoder.container(keyedBy: IngredientMeasureCodingKeys.self)
		let instructionsContainer = try decoder.container(keyedBy: InstructionsStepsCodingKeys.self)
		
		id = try container.decode(String.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		category = try container.decode(String.self, forKey: .category)
		imageURL = try container.decode(String.self, forKey: .imageURL)
		
		let instructions = try instructionsContainer.decodeIfPresent(RecipeStep.self, forKey: .instructions)
		if let instructions {
			steps = instructions.split(regex: "/gm")
		}
		
		let nameKeys = IngredientNameCodingKeys.allCases
		let measureKeys = IngredientMeasureCodingKeys.allCases
		
		for (nameKey, measureKey) in zip(nameKeys, measureKeys) {
			let name = try nameContainer.decodeIfPresent(String.self, forKey: nameKey)
			let measure = try measureContainer.decodeIfPresent(String.self, forKey: measureKey)
			
			if let name = name, let measure = measure,
			   name.isNotEmpty() && measure.isNotEmpty() {
				let ingredient = Model.Ingredient(name: name, measure: measure)
				ingredients.append(ingredient)
			}
		}
	}
}

extension Model.Meal {
	enum CodingKeys: String, CodingKey {
		case id = "idMeal",
			 name = "strMeal",
			 imageURL = "strMealThumb"
	}
}

extension Model.RecipeResponse {
	enum CodingKeys: String, CodingKey {
		case recipes = "meals"
	}
}

extension Model.Recipe {
	enum CodingKeys: String, CodingKey {
		case id = "idMeal",
			 name = "strMeal",
			 category = "strCategory",
			 imageURL = "strMealThumb",
			 steps
	}
	
	enum InstructionsStepsCodingKeys: String, CodingKey {
		case instructions = "strInstructions"
	}
	
	enum IngredientNameCodingKeys: String, CodingKey, CaseIterable {
		case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15, strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
	}
	
	enum IngredientMeasureCodingKeys: String, CodingKey, CaseIterable {
		case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15, strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
	}
}

fileprivate extension String {
	func isNotEmpty() -> Bool {
		!self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
	func isEmpty() -> Bool {
		self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
}


