import Foundation

extension String {
	func split(regex pattern: String) -> [String] {
		let template = "\r\n\r\n"

		let regex = try? NSRegularExpression(pattern: pattern)
		
		let modifiedString = regex?.stringByReplacingMatches(
			in: self,
			range: NSRange(
				location: 0,
				length: count
			),
			withTemplate: template
		)
		
		return modifiedString?.components(separatedBy: template) ?? []
	}
}
