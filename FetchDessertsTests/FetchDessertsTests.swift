import XCTest
@testable import FetchDesserts
@testable import AsyncNet

final class FetchDessertsTests: XCTestCase {
	
	func testDessertServiceMock() async throws {
		do {
			let serviceMock = DessertServiceMock()
			let responseMock = try await serviceMock.getMeals(categoryName: "Dessert")
			XCTAssertEqual(responseMock.meals.first?.id, "53005")
		}
		catch {
			XCTFail("The request should not fail")
		}
	}
	
	@MainActor func testMainViewControllerFetchData() async throws {
		
		let viewController = MealCollectionViewController()
		
		async let expectation = expectation(description: "Fetch data from service")
		
		viewController.mealService = DessertServiceMock()
		let vc = viewController
		let mealResponse = try await vc.fetchData(category: "Dessert")
		
		await expectation.fulfill()
		
		waitForExpectations(timeout: 3.0, handler: nil)
		
		XCTAssertEqual(mealResponse.meals.first?.id, "53005")
	}
}

final class DessertServiceMock: Mockable, MealResponseServiceable, AsyncRequestable {
	
	typealias ResponseModel = Models.MealResponse
	typealias DetailsResponseModel = Models.RecipeResponse
	
	func getMeals(categoryName: String) async throws -> Models.MealResponse {
		return loadJSON(filename: "mock_dessert_response", type: ResponseModel.self)
	}
	
	func getMealDetails(mealId: String) async throws -> Models.RecipeResponse {
		return loadJSON(filename: "mock_desserts_category_response", type: DetailsResponseModel.self)
		
	}
}
