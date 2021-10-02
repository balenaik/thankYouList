import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {

    @IBOutlet private weak var centerRoundedTabBar: CenterRoundedTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        centerRoundedTabBar.customDelegate = self

        let thankYouListViewController = ThankYouListViewController.createViewController()
        let calendarViewController = CalendarViewController.createViewController()

        thankYouListViewController?.tabBarItem.image = R.image.icFormatListBulleted24()
        calendarViewController?.tabBarItem.image = R.image.icCalendarToday24()
        thankYouListViewController?.tabBarItem.title = R.string.localizable.main_tabbar_item_list()
        calendarViewController?.tabBarItem.title = R.string.localizable.main_tabbar_item_calendar()

        let tabs = [thankYouListViewController, calendarViewController].compactMap { $0 }
        setViewControllers(tabs, animated: false)
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

// MARK: - CenterRoundedTabBarDelegate
extension MainTabBarController: CenterRoundedTabBarDelegate {
    func centerRoundedTabBarDidTapCenterButton() {
        guard let viewController = AddThankYouViewController.createViewController() else { return }
        present(viewController, animated: true, completion: nil)
    }
}
