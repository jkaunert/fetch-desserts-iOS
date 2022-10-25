import UIKit
import SwiftUI
import iDoDeclare

/// SwiftUI Canvas Previews for UIViewControllers
/* Usage: `UIViewController`
 struct SomeViewController_Previews: PreviewProvider {
 static var previews: some View {
 PreviewViewController(for: SomeViewController())
 .environment(\.colorScheme, .dark)
 .edgesIgnoringSafeArea(.all)
 }
 }
 */
struct PreviewViewController<ViewControllerType: UIViewController>: UIViewControllerRepresentable {
	
	let `for`: ViewControllerType
	
	func makeUIViewController(context: Context) -> ViewControllerType { `for` }
	
	func updateUIViewController(_ viewController: ViewControllerType, context: Context) {}
}

/// SwiftUI Canvas Previews for UIViews
/* Usage: `UIView`
 struct SomeView_Previews: PreviewProvider {
 static var previews: some View {
 PreviewView(for: SomeView())
 .environment(\.colorScheme, .dark)
 .edgesIgnoringSafeArea(.all)
 }
 }
 */
struct PreviewView<ViewType: UIView>: UIViewRepresentable {
	
	let `for`: ViewType
	
	func makeUIView(context: Context) -> ViewType { `for` }
	
	func updateUIView(_ uiView: ViewType, context: Context) {}
}

