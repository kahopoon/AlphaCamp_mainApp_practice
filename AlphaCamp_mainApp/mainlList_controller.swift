//
//  CourseList_ViewController.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 1/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
