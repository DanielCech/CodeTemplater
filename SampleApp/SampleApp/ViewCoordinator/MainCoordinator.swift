//
//  MainCoordinator.swift
//  SampleApp
//
//  Created by Daniel Cech on 01/05/2020.
//  Copyright © 2020 STRV. All rights reserved.
//

import UIKit

class MainCoordinator {
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var navigationController: UINavigationController!

    func initialViewController() -> UIViewController {
        navigationController = UINavigationController(rootViewController: createFirstViewController())
        return navigationController
    }
}

// MARK: - ViewController Factory
internal extension MainCoordinator {
    func createFirstViewController() -> FirstViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable:next force_cast
        let firstViewController = storyboard.instantiateViewController(identifier: "FirstViewController") as! FirstViewController
        firstViewController.flowDelegate = self
        return firstViewController
    }

    func createSecondViewController() -> SecondViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable:next force_cast
        let secondViewController = storyboard.instantiateViewController(identifier: "SecondViewController") as! SecondViewController
        secondViewController.flowDelegate = self
        return secondViewController
    }

    func createThirdViewController() -> ThirdViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable:next force_cast
        let thirdViewController = storyboard.instantiateViewController(identifier: "ThirdViewController") as! ThirdViewController
        thirdViewController.flowDelegate = self
        return thirdViewController
    }
}

extension MainCoordinator: FirstViewControllerDelegate {
    func firstControllerWillContinue() {
        let controller = createSecondViewController()
        navigationController.pushViewController(controller, animated: true)
    }
}

extension MainCoordinator: SecondViewControllerDelegate {
    func secondControllerWillContinue() {
        let controller = createThirdViewController()
        navigationController.pushViewController(controller, animated: true)
    }
}

extension MainCoordinator: ThirdViewControllerDelegate {
    func thirdControllerWillContinue() {}
}
