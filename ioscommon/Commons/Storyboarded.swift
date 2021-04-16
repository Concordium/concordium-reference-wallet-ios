import UIKit

protocol Storyboarded {
    static func instantiate(fromStoryboard: String, creator: ((NSCoder) -> UIViewController?)?) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(fromStoryboard storyboardName: String, creator: ((NSCoder) -> UIViewController?)? = nil) -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        guard let className = fullName.components(separatedBy: ".").last else {
            fatalError("Cannot find className for \(fullName)")
        }

        // load our storyboard
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        guard let result = storyboard.instantiateViewController(identifier: className, creator: creator) as? Self else {
            fatalError("Cannot instantiate \(className)")
        }
        return result
    }
}
