import UIKit

//UITabBarControllerを継承
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    var viewController: ViewController!
    var calendarVC: CalendarVC!
    override var storyboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        //self.storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vcNavView:UINavigationController =
            self.storyboard.instantiateViewController(withIdentifier: "vcNav") as! UINavigationController
        let calendarVCNavView:UINavigationController =
            self.storyboard.instantiateViewController(withIdentifier: "calendarVCNav") as! UINavigationController
        let addThankYouDataVC = self.storyboard.instantiateViewController(withIdentifier: "addThankYouDataVC") as! ThankYouList.AddThankYouDataVC
        
        //表示するtabItemを指定（今回はデフォルトのItemを使用）
        vcNavView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.featured, tag: 1)
        addThankYouDataVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.featured, tag:2)
        calendarVCNavView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.bookmarks, tag: 3)
        
        // タブで表示するViewControllerを配列に格納します。
        let myTabs = NSArray(objects: vcNavView, addThankYouDataVC, calendarVCNavView)
        
        // 配列をTabにセットします。
        self.setViewControllers(myTabs as? [UIViewController], animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddThankYouDataVC {
            if let addThankYouDataVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "addThankYouDataVC") {
                let navi = UINavigationController(rootViewController: addThankYouDataVC)
                tabBarController.present(navi, animated: true, completion: nil)
            
//            let vcNavView =
//                tabBarController.storyboard?.instantiateViewController(withIdentifier: "vcNav") as! UINavigationController
//            let addThankYouDataVCNav:UINavigationController = tabBarController.storyboard?.instantiateViewController(withIdentifier: "addThankYouDataVCNav") as! UINavigationController
//            if  (addThankYouDataVCNav != nil) {
//                tabBarController.present(addThankYouDataVCNav, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
}
