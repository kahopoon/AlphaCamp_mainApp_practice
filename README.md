# AlphaCamp_mainApp_practice

##Xcode
![Alt text](/screenshots/xcode/storyboard.png?raw=true "storyboard")
![Alt text](/screenshots/xcode/structure.png?raw=true "structure")

##Launching
![Alt text](/screenshots/launching/launch.png?raw=true "launch screen")
![Alt text](/screenshots/launching/login.png?raw=true "login page")

##Guest view (without login)
![Alt text](/screenshots/non-member/events.png?raw=true "events webview")
![Alt text](/screenshots/non-member/people-advisors.png?raw=true "people-advisors webview")
![Alt text](/screenshots/non-member/people-partners.png?raw=true "people-partners webview")
![Alt text](/screenshots/non-member/people-alumni.png?raw=true "people-alumni webview")
![Alt text](/screenshots/non-member/class.png?raw=true "guest class view")
![Alt text](/screenshots/non-member/settings.png?raw=true "guest settings view")

##Member view (logged in)
![Alt text](/screenshots/class.png?raw=true "class view")
![Alt text](/screenshots/class-selection.png?raw=true "class selection")
![Alt text](/screenshots/class-inner.png?raw=true "class inner view")
![Alt text](/screenshots/class-details.png?raw=true "class details webview")
![Alt text](/screenshots/settings.png?raw=true "settings view")
![Alt text](/screenshots/profile-update.png?raw=true "profile update")
![Alt text](/screenshots/profile-updateResponse.png?raw=true "profile update response")

##PrepareLogin_controller.swift
```swift
override func viewWillAppear(animated: Bool) {        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.objectForKey("login_username") != nil && userDefault.objectForKey("login_password") != nil {
            let username = userDefault.objectForKey("login_username"),password = userDefault.objectForKey("login_password")
            loginProcess(username as! String, password: password as! String, completion: { (result) in
                if result == true {
                    dispatch_async(dispatch_get_main_queue()) {
                        let main_screen = self.storyboard!.instantiateViewControllerWithIdentifier("main_screen") as! UITabBarController
                        self.presentViewController(main_screen, animated:true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("showLogin", sender: self)
                    }
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
        }
    }
```
start of the app, it will first search if userdefault contains login information. if no, redirect to login page, if yes, execute login process that defined on LoginProcess_function.swift. if action success, redirect to main_screen (at tabbar controller), if failed, rediect to login page
