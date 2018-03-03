import UIKit
import FirebaseAuth

//UITabBarControllerを継承
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    var viewController: ViewController!
    var calendarVC: CalendarVC!
    var uid: String?
    
    // Set colors
    let tabBarBgColor = UIColor(colorWithHexValue: 0xf2f7f2)
    let tabBarTextColor = UIColor(colorWithHexValue: 0xfe939d)
    
    override var storyboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let vcNavView:UINavigationController =
            self.storyboard.instantiateViewController(withIdentifier: "vcNav") as! UINavigationController
        let calendarVCNavView:UINavigationController =
            self.storyboard.instantiateViewController(withIdentifier: "calendarVCNav") as! UINavigationController
        let addThankYouDataVC = self.storyboard.instantiateViewController(withIdentifier: "addThankYouDataVC") as! ThankYouList.AddThankYouDataVC
        
        //表示するtabItemを指定
        vcNavView.tabBarItem.image = UIImage(named: "list")?.resize(size: CGSize(width: 25, height: 25))
        addThankYouDataVC.tabBarItem.image = UIImage(named: "add_button")?.resize(size: CGSize(width: 35, height: 35))?.withRenderingMode(.alwaysOriginal)
        addThankYouDataVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5,0,-5,0)
        calendarVCNavView.tabBarItem.image = UIImage(named: "calendar")
        
        // Set titles to the tabbar
        vcNavView.tabBarItem.title = "List"
        calendarVCNavView.tabBarItem.title = "Calendar"
        
        // Set colors
        let selectedAttributes = [NSAttributedStringKey.foregroundColor: self.tabBarTextColor]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: UIControlState.selected)
        UITabBar.appearance().tintColor = self.tabBarTextColor
        UITabBar.appearance().barTintColor = self.tabBarBgColor
        UITabBar.appearance().selectionIndicatorImage = UIImage().createSelectionIndicator(color: self.tabBarTextColor, size: CGSize(width: tabBar.frame.width/3, height: tabBar.frame.height), lineWidth: 3.0)
        
        // タブで表示するViewControllerを配列に格納します。
        let myTabs = NSArray(objects: vcNavView, addThankYouDataVC, calendarVCNavView)
        
        
        // Set today's date and pass it to the addThankYouDataVC
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        appDelegate.selectedDate = formatter.string(from: now as Date)
        
        // Authentication
        Auth.auth().signInAnonymously() { (user, error) in
            if let e = error {
                print(e)
                print("login error")
                return
            }
            print("uid: \(user!.uid)")
            let isAnonymous = user!.isAnonymous  // true
            self.uid = user!.uid
            self.createViewController(vcs: myTabs as! [UIViewController])
        }
    }
    
    func createViewController(vcs: [UIViewController]) {
        // 配列をTabにセットします。
        self.setViewControllers(vcs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddThankYouDataVC {
            if let addThankYouDataVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "addThankYouDataVC") {
                let navi = UINavigationController(rootViewController: addThankYouDataVC)
                tabBarController.present(navi, animated: true, completion: nil)
                return false
            }
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
