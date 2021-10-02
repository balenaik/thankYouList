import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        let thankYouListViewController =
            UIStoryboard(name: "ThankYouList", bundle: nil).instantiateInitialViewController()!
        let thankYouListNavigation = UINavigationController(rootViewController: thankYouListViewController)
        let thankYouCalendarViewController = UIStoryboard(name: "ThankYouCalendar", bundle: nil).instantiateInitialViewController()!
        let thankYouCalendarNavigation = UINavigationController(rootViewController: thankYouCalendarViewController)

        thankYouListNavigation.tabBarItem.image = R.image.icFormatListBulleted24()
        thankYouCalendarNavigation.tabBarItem.image = R.image.icCalendarToday24()
        thankYouListNavigation.tabBarItem.title = "List"
        thankYouCalendarNavigation.tabBarItem.title = "Calendar"

        let tabs = [thankYouListNavigation, thankYouCalendarNavigation]
        createViewController(vcs: tabs)
    }
    
    func createViewController(vcs: [UIViewController]) {
        self.setViewControllers(vcs, animated: false)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddThankYouViewController {
            // Need to create ViewController every time
            let addThankYouViewController = UIStoryboard(name: "AddThankYou", bundle: nil).instantiateInitialViewController()!
            let navigationController = UINavigationController(rootViewController: addThankYouViewController)
            tabBarController.present(navigationController, animated: true, completion: nil)
            return false
        }
        return true
    }
}

// MARK: - Public
extension MainTabBarController {
    static func createViewController() -> MainTabBarController? {
        guard let viewController = R.storyboard.mainTabBar().instantiateInitialViewController() as? MainTabBarController else {
            return nil
        }
        return viewController
    }
}
