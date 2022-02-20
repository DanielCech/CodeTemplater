//
//  SecondViewController.swift
//  SampleApp
//
//  Created by Daniel Cech on 01/05/2020.
//  Copyright © 2020 STRV. All rights reserved.
//

import UIKit

protocol SecondViewControllerDelegate: AnyObject {
    func secondControllerWillContinue()
}

class SecondViewController: UIViewController {
    weak var flowDelegate: SecondViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func view(_: Int) {
        // some method
    }

    @IBAction private func continueToNextScreen() {
        flowDelegate?.secondControllerWillContinue()
    }
}
