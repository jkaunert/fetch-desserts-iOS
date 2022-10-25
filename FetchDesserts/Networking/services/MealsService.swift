import Foundation
import AsyncNet

protocol MealResponseServiceable: ResponseModelServiceable where DetailsResponseModel == Models.RecipeResponse, ResponseModel == Models.MealResponse {
	
	func getMeals(categoryName: String) async throws -> ResponseModel
	
	func getMealDetails(mealId: String) async throws -> DetailsResponseModel
	
}

struct MealsService: MealResponseServiceable, AsyncRequestable {
	typealias ResponseModel = Models.MealResponse
	typealias DetailsResponseModel = Models.RecipeResponse
	
	func getMeals(categoryName: String) async throws -> ResponseModel {
		return try await sendRequest(to: MealsEndpoint.category(categoryName: categoryName))
	}
	
	func getMealDetails(mealId: String) async throws -> DetailsResponseModel {
		return try await sendRequest(to: MealsEndpoint.recipe(mealId: mealId))
	}
}

