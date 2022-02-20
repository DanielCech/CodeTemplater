// ___FILEHEADER___

import Swinject
import UIKit

final class ___FILEBASENAMEASIDENTIFIER___ {
    var childCoordinators = [Coordinator]()
    let assembler: Assembler

    let tabBarController: UITabBarController

    init(tabBarController: UITabBarController, assembler: Assembler) {
        self.tabBarController = tabBarController
        self.assembler = assembler
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___ing

extension ___FILEBASENAMEASIDENTIFIER___: ___FILEBASENAMEASIDENTIFIER___ing {
    func start() {
        tabBarController.viewControllers = [
            makeRootViewController(),
        ]
    }
}

// MARK: - Factories

// Extension is internal to be accessible from test target
internal extension ___FILEBASENAMEASIDENTIFIER___ {
    func makeRootViewController() -> UIViewController {
        // DO NOT FORGET TO ADD VIEW MODEL TO `ViewModelAssembly.swift`
//        let viewController = R.storyboard.specificViewController.instantiateInitialViewController(
//            viewModel: resolve(SpecificViewModel.self)
//        )
//        viewController.coordinator = self

        return UIViewController()
    }
}
