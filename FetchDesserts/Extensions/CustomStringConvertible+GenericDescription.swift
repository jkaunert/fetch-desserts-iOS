import Foundation

extension CustomStringConvertible where Self: Codable {
	var description: String {
		var description = "\n \(type(of: self)) \n"
		let selfMirror = Mirror(reflecting: self)
		for child in selfMirror.children {
			if let propertyName = child.label {
				description += "\(propertyName): \(child.value)\n"
			}
		}
		return description
	}
}
