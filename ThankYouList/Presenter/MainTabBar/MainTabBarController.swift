import UIKit
import FirebaseAuth

//UITabBarControllerを継承
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    var viewController: ThankYouListViewController!
    var calendarVC: CalendarViewController!
    var uid: String?
    var tabsArray: [UIViewController]?
    
    // Set colors
    let tabBarBgColor = UIColor(colorWithHexValue: 0xf2f7f2)
    let tabBarTextColor = UIColor(colorWithHexValue: 0xfe939d)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        let thankYouListViewController =
            UIStoryboard(name: "ThankYouList", bundle: nil).instantiateInitialViewController()!
        let thankYouListNavigation = UINavigationController(rootViewController: thankYouListViewController)
        let thankYouCalendarViewController = UIStoryboard(name: "ThankYouCalendar", bundle: nil).instantiateInitialViewController()!
        let thankYouCalendarNavigation = UINavigationController(rootViewController: thankYouCalendarViewController)
        let addThankYouViewController = UIStoryboard(name: "AddThankYou", bundle: nil).instantiateInitialViewController()!
        
        //表示するtabItemを指定
        thankYouListNavigation.tabBarItem.image = UIImage(named: "list")?.resize(size: CGSize(width: 25, height: 25))
        addThankYouViewController.tabBarItem.image = UIImage(named: "add_button")?.resize(size: CGSize(width: 35, height: 35))?.withRenderingMode(.alwaysOriginal)
        addThankYouViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5,left: 0,bottom: -5,right: 0)
        thankYouCalendarNavigation.tabBarItem.image = UIImage(named: "calendar")
        
        // Set titles to the tabbar
        thankYouListNavigation.tabBarItem.title = "List"
        thankYouCalendarNavigation.tabBarItem.title = "Calendar"
        
        // Set colors
        let selectedAttributes = [NSAttributedString.Key.foregroundColor: self.tabBarTextColor]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: UIControl.State.selected)
        UITabBar.appearance().tintColor = self.tabBarTextColor
        UITabBar.appearance().barTintColor = self.tabBarBgColor
        UITabBar.appearance().selectionIndicatorImage = UIImage().createSelectionIndicator(color: self.tabBarTextColor, size: CGSize(width: tabBar.frame.width/3, height: tabBar.frame.height), lineWidth: 3.0)
        
        // タブで表示するViewControllerを配列に格納します。
        tabsArray = NSArray(objects: thankYouListNavigation, addThankYouViewController, thankYouCalendarNavigation) as? [UIViewController]
        
        self.createViewController(vcs: tabsArray!)
    }
    
    
    func createViewController(vcs: [UIViewController]) {
        self.setViewControllers(vcs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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


extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint(x: 0,y :size.height - lineWidth), size: CGSize(width: size.width, height: lineWidth)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
