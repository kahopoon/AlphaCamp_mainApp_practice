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

##mainList_controller.swift
```swift
class mainList_controller: UITableViewController {

    @IBOutlet weak var courseListTitleName: UILabel!
    
    var isGuest:Bool!
    
    let request_url:String = "https://dojo.alphacamp.co/api/v1/courses"
    var request_resource:String = ""
    var request_apikey:String = "?api_key=b21fc7ea8e6f7355e3052de9a49ba342b5204adb&auth_token="
    var request_token:String = ""
    
    var data : NSData!
    
    var mainCatergory = [[String:String]]()
    var courseListData = [[[String:String]]]()
    var courseFutherData = [[[[String:String]]]]()
    var currentView = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isGuest = NSUserDefaults.standardUserDefaults().objectForKey("login_username") == nil ? true : false
        
        //nav apperance settings
        self.navigationController!.navigationBar.translucent = false
        navigationItem.titleView = navDefault()
 
        //get course data only if not guess
        if !isGuest {
            //get & assign request token
            let userDefault = NSUserDefaults.standardUserDefaults()
            request_token = String(userDefault.objectForKey("session_auth_token")!)
            
            
            //get main catergory raw data
            data = NSData(contentsOfURL: NSURL(string: request_url + request_resource + request_apikey + request_token)!)
            
            //manipulate main category data
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    readMainCatergory(dictionary)
                    
                    //init table list header title
                    courseListTitleName.text = mainCatergory[currentView]["name"]
                    
                    //nav right button (course choice)
                    let courseChoice = UIBarButtonItem(title: "Course", style: .Plain, target: self, action: #selector(mainList_controller.courseChoice))
                    navigationItem.rightBarButtonItems = [courseChoice]
                }
            } catch {
                // Handle Error
            }
            
            //manipulate course list data under main category
            if mainCatergory.count > 0 {
                for loop in 0...mainCatergory.count-1 {
                    request_resource = "/" + mainCatergory[loop]["id"]!
                    data = nil
                    data = NSData(contentsOfURL: NSURL(string: request_url + request_resource + request_apikey + request_token)!)
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        if let dictionary = object as? [String: AnyObject] {
                            readCourseList(dictionary)
                        }
                    } catch {
                        // Handle Error
                    }
                }
            }
        } else {
            courseListTitleName.text = "Please login to view your courses"
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    //main category data insert into dictionary
    func readMainCatergory(object: [String: AnyObject]) {
        guard let courses = object["courses"] as? [[String: AnyObject]] else { return }
        for course in courses {
            guard let id = course["id"] as? String, let url = course["url"] as? String, let name =  course["name"] as? String else { break }
            mainCatergory.append(["name":name, "url":url, "id":id])
        }
    }
    
    //main couse list data insert into dictionary, also additional data for further request on table view
    func readCourseList(object: [String: AnyObject]) {
        var tempData = [[String:String]]()
        var futherData = [[[String:String]]]()
        guard let all_syllabus = object["syllabus"] as? [[String: AnyObject]] else { return }
        for syllabus in all_syllabus {
            guard let section = syllabus["section"] as? [String: AnyObject], let lessons = syllabus["lessons"] as? [[String: AnyObject]] else { return }
            tempData.append(["id":String(section["id"]!), "name":String(section["name"]!)])
            var tempFurtherData = [[String:String]]()
            for lesson in lessons {
                guard let name = lesson["name"] as? String, let url = lesson["url"] as? String else { break }
                tempFurtherData.append(["name":name, "url":url])
            }
            futherData.append(tempFurtherData)
        }
        courseListData.append(tempData)
        courseFutherData.append(futherData)
    }
    
    //action sheet of course choice
    func courseChoice() {
        let courseChoiceController = UIAlertController(title: "Course List", message: "Choose a course", preferredStyle: .ActionSheet)
        if mainCatergory.count > 0 {
            for loop in 0...mainCatergory.count-1 {
                courseChoiceController.addAction(UIAlertAction(title: mainCatergory[loop]["name"], style: .Default, handler:
                    { (action:UIAlertAction) -> Void in
                        self.currentView = loop
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                }))
            }
        }
        self.presentViewController(courseChoiceController, animated: true, completion: nil)
    }
    
    //send further data to next table view by segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCourseItems" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! courseItems_controller
                controller.courseTitle = courseListData[currentView][indexPath.row]["name"]
                controller.courseData = courseFutherData[currentView][indexPath.row]
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return !isGuest ? courseListData[currentView].count : 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mainList_cell", forIndexPath: indexPath) as! mainList_cell
        
        // Configure the cell...
        let currentData : Dictionary = self.courseListData[currentView][indexPath.row]
        cell.nameShow.text = currentData["name"]!
        return cell
    }
}
```
the most critical part of app, first will determine if viewer is guest, if so, no network requests on this page, else take the token from before's login process and make further request. first it grep on course's main catergory and save on main category dictionary, then request each course data and save to course list dictionary. as api contains the further data of course at same request, it also manipulate the further data of course and save to further data dictionary, it's 4 dimension data structure, handle with care. main category data also use for the action sheet at nav bar, at segue, send further data to next view.  

##courseItems_controller.swift
```swift
preLoginWebView()
```
nothing special on this view, just manipulate data from previous view. but in this view, it will call a function "preLoginWebView()", purpose is to use userdefault to pre login at webview, so that user will not need to have second login at app.  

##PreLoginWebView.swift
```swift
func preLoginWebView() {
    let userDefault = NSUserDefaults.standardUserDefaults()
    let url = NSURL(string: "https://dojo.alphacamp.co/users/sign_in" )
    var authenticity_token:String = ""
    let session = NSURLSession.sharedSession()
    session.dataTaskWithRequest(NSMutableURLRequest(URL: url!)) {(data, response, error) in
        authenticity_token = String(NSString(data: data!, encoding: NSUTF8StringEncoding))
        dispatch_async(dispatch_get_main_queue()) {
            let pattern = "authenticity_token\" value=\""
            if let match = authenticity_token.rangeOfString(pattern + "(.+?)" + "\"", options: .RegularExpressionSearch) {
                authenticity_token = String(authenticity_token.substringWithRange(match).stringByReplacingOccurrencesOfString(pattern, withString: "").characters.dropLast())
                let login_request = NSMutableURLRequest(URL: url!)
                let innerAuth = ["email": String(userDefault.objectForKey("login_username")!), "password": String(userDefault.objectForKey("login_password")!), "remember_me": "1"]
                let mainAuth = ["authenticity_token": authenticity_token, "platform": "mobileApp", "user":innerAuth]
                login_request.HTTPMethod = "POST"
                login_request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                login_request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(mainAuth, options: .PrettyPrinted)
                session.dataTaskWithRequest(login_request) { data, response, error in
                    //let data = String(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    //print(data)
                    }.resume()
            }
        }
        }.resume()
}
```
here is the function of pre-login web view  

##itemDetail_controller.swift
```swift
class itemDetail_controller: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var detailWebView: UIWebView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var responseURL:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nav apperance settings
        self.navigationController!.navigationBar.translucent = false
        navigationItem.titleView = navDefault()
        
        activity.color = UIColor.orangeColor()
        
        let request = NSURLRequest(URL: NSURL(string: responseURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!)
        
        detailWebView.loadRequest(request)
        detailWebView.delegate = self
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activity.hidden = false
        activity.startAnimating()
        loadingLabel.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activity.hidden = true
        activity.stopAnimating()
        loadingLabel.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
    }
}
```
more than webview, here we practice activity indicator, how ui label show and hide...  

##AboutUS_controller.swift
```swift
@IBOutlet weak var changeViewSegmentedControl: UISegmentedControl!
    @IBAction func changeView(sender: AnyObject) {
        switch changeViewSegmentedControl.selectedSegmentIndex {
        case 0:
            responseURL = "https://www.alphacamp.co/our-advisors/"
            webViewRequest()
        case 1:
            responseURL = "https://www.alphacamp.co/our-partner/"
            webViewRequest()
        case 2:
            responseURL = "https://www.alphacamp.co/student-experiences/"
            webViewRequest()
        default:
            break;
        }
    }
```
nothing special on events view, so just skip it. at About US view, we implemented segmented control at view. perform different webview request when user click on different segment.  

