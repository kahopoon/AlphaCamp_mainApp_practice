//
//  itemDetail_controller.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 7/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

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
