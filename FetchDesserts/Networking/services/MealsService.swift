import Foundation
import AsyncNet

protocol MealResponseServiceable: ResponseModelServiceable where DetailsResponseModel == Model.RecipeResponse, ResponseModel == Model.MealResponse {
	
	func getMeals(categoryName: String) async throws -> ResponseModel
	func getMealDetails(mealId: String) async throws -> DetailsResponseModel
}

struct MealsService: MealResponseServiceable, AsyncRequestable {
	typealias ResponseModel = Model.MealResponse
	typealias DetailsResponseModel = Model.RecipeResponse
	
	func getMeals(categoryName: String) async throws -> ResponseModel {
		return try await sendRequest(to: MealsEndpoint.category(categoryName: categoryName))
	}
	
	func getMealDetails(mealId: String) async throws -> DetailsResponseModel {
		return try await sendRequest(to: MealsEndpoint.recipe(mealId: mealId))
	}
}

