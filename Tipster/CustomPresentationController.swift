//
//  CustomPresentationController.swift
//  Tipster
//
//  Created by Atul Acharya on 9/23/16.
//
//

import UIKit

// Source: Code from Apple's Custom Transitions example

@objc (CustomPresentationController)
class CustomPresentationController: UIPresentationController,
    UIViewControllerTransitioningDelegate,
    UIViewControllerAnimatedTransitioning
    
{
    
    // Corner radius applied to the view containing the presented view controller
    private let CORNER_RADIUS: CGFloat = 16.0
    
    private var dimmingView: UIView?
    private var presentationWrappingView: UIView?
    
    // MARK: - Lifecycle
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        // the presented VC must have a modalPresentation style of Custom
        presentedViewController.modalPresentationStyle = .Custom
    }
    
    override func presentedView() -> UIView? {
        // return the wrapping view created in -presentationTransitionWillBegin
        return self.presentationWrappingView
    }
    
    // MARK: - Transitions
    
    override func presentationTransitionWillBegin() {
        
        let presentedViewControllerView = super.presentedView()!
        
        // Wrap the presented view controller's view in an intermediate hierarchy
        // that applies a shadow and rounded corners to the top-left and top-right
        // edges.  The final effect is built using three intermediate views.
        //
        // presentationWrapperView              <- shadow
        //   |- presentationRoundedCornerView   <- rounded corners (masksToBounds)
        //        |- presentedViewControllerWrapperView
        //             |- presentedViewControllerView (presentedViewController.view)
        //
        do {
            // 1 -
            let presentationWrapperView = UIView(frame: self.frameOfPresentedViewInContainerView())
            presentationWrapperView.layer.shadowOpacity = 0.44
            presentationWrapperView.layer.shadowRadius = 13.0
            presentationWrapperView.layer.shadowOffset = CGSizeMake(0, -6.0)
            self.presentationWrappingView = presentationWrapperView
            
            // 2 -
            let presentationRoundedCornerView = UIView(frame: UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsetsMake(0, 0, -CORNER_RADIUS, 0)))
            presentationRoundedCornerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            presentationRoundedCornerView.layer.cornerRadius = CORNER_RADIUS
            presentationRoundedCornerView.layer.masksToBounds = true
            
            // 3 -
            let presentedViewControllerWrapperView = UIView(frame: UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsetsMake(0, 0, CORNER_RADIUS, 0)))
            presentedViewControllerWrapperView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            // 4 - Add presentedViewControllerView -> presentedViewControllerWrapperView
            presentedViewControllerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
            presentedViewControllerWrapperView.addSubview(presentedViewControllerView)
            
            // 5 - Add presentedViewControllerWrapperView -> presentationRoundedCornerView
            presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
            
            // 6 - Add presentationRoundedCornerView -> presentationWrapperView
            presentationWrapperView.addSubview(presentationRoundedCornerView)
        }
        
        // Add a dimming view behind presentationWrapperView.  self.presentedView
        // is added later (by the animator) so any views added here will be
        // appear behind the -presentedView.
        do {
            let dimmingView = UIView(frame: self.containerView?.bounds ?? CGRect())
            dimmingView.backgroundColor = UIColor.blackColor()
            dimmingView.opaque = false
            dimmingView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.dimmingViewTapped(_:))))
            self.dimmingView = dimmingView
            self.containerView?.addSubview(dimmingView)
            
            // Get the transition coordinator for the presentation so we can
            // fade in the dimmingView alongside the presentation animation.
            let transitionCoordinator = self.presentingViewController.transitionCoordinator()
            
            self.dimmingView?.alpha = 0.0
            transitionCoordinator?.animateAlongsideTransition({context in
                self.dimmingView?.alpha = 0.5
                }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator()
        
        transitionCoordinator?.animateAlongsideTransition({context in
            self.dimmingView?.alpha = 0.0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    // MARK: - Layout
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        super.preferredContentSizeDidChangeForChildContentContainer(container)
        
        if container === self.presentedViewController {
            self.containerView?.setNeedsLayout()
        }
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === self.presentedViewController {
            return (container as! UIViewController).preferredContentSize
        } else {
            return
                super.sizeForChildContentContainer(container, withParentContainerSize: parentSize)
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let containerViewBounds = self.containerView?.bounds ?? CGRect()
        let presentedViewContentSize = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height
        return presentedViewControllerFrame
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.dimmingView?.frame = self.containerView?.bounds ?? CGRect()
        self.presentationWrappingView?.frame = self.frameOfPresentedViewInContainerView()
    }
    
    // MARK: - Tap Gesture Recognizer
    @IBAction func dimmingViewTapped(sender: UITapGestureRecognizer) {
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return transitionContext?.isAnimated() ?? false ? 0.35 : 0
    }
    
    //| ----------------------------------------------------------------------------
    //  The presentation animation is tightly integrated with the overall
    //  presentation so it makes the most sense to implement
    //  <UIViewControllerAnimatedTransitioning> in the presentation controller
    //  rather than in a separate object.
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()!
        
        // For a Presentation:
        //      fromView = The presenting view.
        //      toView   = The presented view.
        // For a Dismissal:
        //      fromView = The presented view.
        //      toView   = The presenting view.
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        
        let isPresenting = (fromViewController === self.presentingViewController)
        
        let _ = transitionContext.initialFrameForViewController(fromViewController)
        
        var fromViewFinalFrame = transitionContext.finalFrameForViewController(fromViewController)
        var toViewInitialFrame = transitionContext.initialFrameForViewController(toViewController)
        let toViewFinalFrame = transitionContext.finalFrameForViewController(toViewController)
        
        if toView != nil {
            containerView.addSubview(toView!)
        }
        
        if isPresenting {
            toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), CGRectGetMaxY(containerView.bounds))
            toViewInitialFrame.size = toViewFinalFrame.size
            toView?.frame = toViewInitialFrame
        } else {
            fromViewFinalFrame = CGRectOffset(fromView?.frame ?? CGRect(),
                                              0,
                                              CGRectGetHeight(fromView?.frame ?? CGRect()))
            
        }
        
        let transitionDuration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        UIView.animateWithDuration(transitionDuration,
                                   animations: {
                                    if isPresenting {
                                        toView?.frame = toViewFinalFrame
                                    } else {
                                        fromView?.frame = fromViewFinalFrame
                                    }
            }, completion: {finished in
                let wasCancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!wasCancelled)
        })
        
    }
    
    // MARK: - UIViewController Transitioning Delegate
    
    @objc func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        assert(self.presentedViewController === presented,
               "You didn't initialize \(self) with the correct presentedViewController.  Expected \(presented), got \(self.presentedViewController).")
        
        return self
    }
    
    @objc func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self
    }
    
    @objc func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self
    }
    
}

