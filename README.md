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

##Login_controller.swift
```swift
@IBAction func loginAction(sender: AnyObject) {
        warningLabel.hidden = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        if loginEmail.hasText() && loginPassword.hasText() {
            let username = loginEmail.text, password = loginPassword.text
            loginProcess(username!, password: password!, completion: { (result) in
                if result == true {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("showCourse", sender: self)
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        activityIndicatorView.stopAnimating()
                        self.warningLabel.text = "Incorrect username / password !"
                        self.warningLabel.hidden = false
                    }
                }
            })
        } else {
            activityIndicatorView.stopAnimating()
            self.warningLabel.text = "Enter username / password !"
            self.warningLabel.hidden = false
        }
    }
    
    @IBAction func guestView(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let guestView = self.storyboard?.instantiateViewControllerWithIdentifier("main_screen") as! UITabBarController
            guestView.selectedIndex = 1
            self.presentViewController(guestView, animated: true, completion: nil)
        }
    }
```
login page, call login process if user's input are complete else showing input error, if login process succeed, redirect to tab bar screen to start else showing credentials error. if user click view as guest, direct forward to tab bar screen.  

##LoginProcess_function.swift
```swift
func loginProcess(username: String, password: String, completion: ((result:Bool?) -> Void)!) {
    let url = NSURL(string: "https://dojo.alphacamp.co/api/v1/login?api_key=b21fc7ea8e6f7355e3052de9a49ba342b5204adb")
    let urlRequest = NSMutableURLRequest(URL: url!)
    urlRequest.HTTPMethod = "POST"
    var postStr: String = ""
    postStr = "email=" + username + "&password=" + password
    let data = postStr.dataUsingEncoding(NSUTF8StringEncoding)
    urlRequest.HTTPBody = data
    let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { (returnData:NSData?,
        res:NSURLResponse?, err:NSError?) -> Void in
        if let returnData = returnData {
            do {
                let dic = try NSJSONSerialization.JSONObjectWithData(returnData , options:
                    NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let status = dic["message"] as! String
                var token:String!
                if status == "Ok" {
                    token = dic["auth_token"] as! String
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    userDefault.setObject(token, forKey: "session_auth_token")
                    userDefault.setObject(username, forKey: "login_username")
                    userDefault.setObject(password, forKey: "login_password")
                    userDefault.synchronize()
                    completion(result: true)
                }
                else {
                    completion(result: false)
                }
            } catch {
            }
        }
    }
    task.resume()
}
```
login process, if success, record into userdefault.  

##navDefault.swift
```swift
func navDefault() -> UIImageView {
    let titleImage = UIImageView(image: UIImage(named: "ALPHACamp"))
    titleImage.frame.size.width = UIScreen.mainScreen().bounds.width / 2.5
    titleImage.frame.size.height = titleImage.frame.size.width / 4
    titleImage.contentMode = UIViewContentMode.ScaleAspectFit
    return titleImage
}
```
nothing special here, just put nav appearance outside to keep code cleaner...  

