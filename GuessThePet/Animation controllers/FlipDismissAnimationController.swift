///// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class FlipDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  private let destinationFrame: CGRect
  
  let interactionController: SwipeInteractionController?
  
  init(destinationFrame: CGRect, interactionController: SwipeInteractionController?) {
    self.destinationFrame = destinationFrame
    self.interactionController = interactionController
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    //Take a snapshot of the "from" view
    guard let fromVC = transitionContext.viewController(forKey: .from),
    let toVC = transitionContext.viewController(forKey: .to),
    let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
      else {
        return
    }
    
    snapshot.layer.cornerRadius = CardViewController.cardCornerRadius
    snapshot.layer.masksToBounds = true
    
    //The order of layers is important. They must be in the order: “to” view, “from” view, snapshot view
    let containerView = transitionContext.containerView
    containerView.insertSubview(toVC.view, at: 0)
    containerView.addSubview(snapshot)
    fromVC.view.isHidden = true
    
    //Rotate the “to” view to be edge-on so that it isn’t immediately revealed when rotating the snapshot
    AnimationHelper.perspectiveTransform(for: containerView)
    toVC.view.layer.transform = AnimationHelper.yRotation(-.pi/2)
    let duration = transitionDuration(using: transitionContext)
    
    UIView.animateKeyframes(withDuration: duration,
                            delay: 0,
                            options: .calculationModeCubic,
                            animations: {
                              //Scale the snapshot view down, hide it by rotating it 90˚
                              //Reveal the “to” view by rotating it back from its edge-on position
                              UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
                                snapshot.frame = self.destinationFrame
                              }
                              UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
                                snapshot.layer.transform = AnimationHelper.yRotation(.pi/2)
                              }
                              UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
                                toVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                              }
                              
    },
                            //Remove the snapshot and restore the state of the “from” view
                            completion: { _ in
                              fromVC.view.isHidden = false
                              snapshot.removeFromSuperview()
                              if transitionContext.transitionWasCancelled {
                                toVC.view.removeFromSuperview()
                              }
                              transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                              
    })
  }
}
