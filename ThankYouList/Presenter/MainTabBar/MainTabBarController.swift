import UIKit
import FirebaseAuth

private let tabBarTitleFontSize = CGFloat(11)

protocol MainTabBarRouter {
    func presentAddThankYou()
}

class MainTabBarController: UITabBarController {

    @IBOutlet private weak var centerRoundedTabBar: CenterRoundedTabBar!

    var thankYouListNavigationController: UINavigationController?
    var calendarNavigationController: UINavigationController?

    var router: MainTabBarRouter?

    override func viewDidLoad() {
        super.viewDidLoad()

        centerRoundedTabBar.customDelegate = self

        thankYouListNavigationController?.tabBarItem.image = R.image.icFormatListBulleted24()
        calendarNavigationController?.tabBarItem.image = R.image.icCalendarToday24()
        thankYouListNavigationController?.tabBarItem.title = R.string.localizable.main_tabbar_item_list()
        calendarNavigationController?.tabBarItem.title = R.string.localizable.main_tabbar_item_calendar()

        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.regularAvenir(ofSize: tabBarTitleFontSize)],
            for: .normal
        )
    }
}

// MARK: - CenterRoundedTabBarDelegate
extension MainTabBarController: CenterRoundedTabBarDelegate {
    func centerRoundedTabBarDidTapCenterButton() {
        router?.presentAddThankYou()
    }
}
