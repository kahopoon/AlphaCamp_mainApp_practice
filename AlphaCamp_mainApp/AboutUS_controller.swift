//
//  AboutUS_controller.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 9/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

class AboutUS_controller: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var aboutUSWebView: UIWebView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var responseURL:String = "https://www.alphacamp.co/our-advisors/"
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nav apperance settings
        self.navigationController!.navigationBar.translucent = false
        navigationItem.titleView = navDefault()
        
        activity.color = UIColor.orangeColor()
        
        webViewRequest()
        
        aboutUSWebView.delegate = self
    }
    
    func webViewRequest() {
        let request = NSURLRequest(URL: NSURL(string: responseURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!)
        aboutUSWebView.loadRequest(request)
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
