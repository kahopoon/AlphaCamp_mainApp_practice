//
//  navDefault_controller.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 9/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

func navDefault() -> UIImageView {
    let titleImage = UIImageView(image: UIImage(named: "ALPHACamp"))
    titleImage.frame.size.width = UIScreen.mainScreen().bounds.width / 2.5
    titleImage.frame.size.height = titleImage.frame.size.width / 4
    titleImage.contentMode = UIViewContentMode.ScaleAspectFit
    return titleImage
}