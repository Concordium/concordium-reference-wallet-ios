//
//  OnboardingCarouselPageViewController.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 08/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

protocol OnboardingCarouselPageViewControllerDelegate: AnyObject {
    func didChangePage(_ index: Int)
}

final class OnboardingCarouselPageViewController: UIPageViewController {

    weak var controllerDelegate: OnboardingCarouselPageViewControllerDelegate?
    private(set) var orderedViewControllers = [UIViewController]()

    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
    }

    func setup(with orderedViewControllers: [UIViewController]) {
        self.orderedViewControllers = orderedViewControllers

        guard let firstViewController = orderedViewControllers.first else { return }

        setViewControllers(
            [firstViewController],
            direction: .forward,
            animated: true
        )
    }

    func goToNextPage() {
        let currentIndex = presentationIndex(for: self)

        guard currentIndex >= 0 && (currentIndex + 1) < orderedViewControllers.count else { return }

        let nextViewController = orderedViewControllers[orderedViewControllers.index(after: currentIndex)]

        setViewControllers(
            [nextViewController],
            direction: .forward,
            animated: true
        )

        controllerDelegate?.didChangePage(presentationIndex(for: self))
    }

    func goToPreviousPage() {
        let currentIndex = presentationIndex(for: self)

        guard currentIndex > 0 else { return }

        let previousViewController = orderedViewControllers[orderedViewControllers.index(before: currentIndex)]

        setViewControllers(
            [previousViewController],
            direction: .reverse,
            animated: true
        )

        controllerDelegate?.didChangePage(presentationIndex(for: self))
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingCarouselPageViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard
            let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController)
        else {
            return 0
        }

        return firstViewControllerIndex
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard
            orderedViewControllersCount != nextIndex,
            orderedViewControllersCount > nextIndex
        else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard
            previousIndex >= 0,
            orderedViewControllers.count > previousIndex
        else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingCarouselPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        controllerDelegate?.didChangePage(presentationIndex(for: pageViewController))
    }
}
