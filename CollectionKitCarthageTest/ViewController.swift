//
//  ViewController.swift
//  CollectionKitCarthageTest
//
//  Created by Luke Zhao on 2018-09-23.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import UIKit
import CollectionKit

class ViewController: UIViewController {
  let collectionView = CollectionView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)

    collectionView.provider = BasicProvider(
      dataSource: ArrayDataSource(data: Array(0..<100)),
      viewSource: ClosureViewSource(
        viewGenerator: { (data, index) -> UILabel in
          print("view generated at \(index)")
          return UILabel()
        },
        viewUpdater: { (cell: UILabel, data, index) in
          cell.text = "\(data)"
      }),
      sizeSource: { index, data, collectionSize in
        // 2. return size for each StoryItemCell here
        return CGSize(width: 100, height: 100)
      }
    )
    collectionView.animator = AnimatedReloadAnimator()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }

}


class AnimatedReloadAnimator: Animator {
  static let defaultEntryTransform: CATransform3D = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 1), 0, 0, -1)
  static let fancyEntryTransform: CATransform3D = {
    var trans = CATransform3DIdentity
    trans.m34 = -1 / 500
    return CATransform3DScale(CATransform3DRotate(CATransform3DTranslate(trans, 0, -50, -100), 0.5, 1, 0, 0), 0.8, 0.8, 1)
  }()

  let entryTransform: CATransform3D

  init(entryTransform: CATransform3D = defaultEntryTransform) {
    self.entryTransform = entryTransform
    super.init()
  }

  override func delete(collectionView: CollectionView, view: UIView) {
    if collectionView.isReloading, collectionView.bounds.intersects(view.frame) {
      UIView.animate(withDuration: 0.25, animations: {
        view.layer.transform = self.entryTransform
        view.alpha = 0
      }, completion: { _ in
        if !collectionView.visibleCells.contains(view) {
          view.recycleForCollectionKitReuse()
          view.transform = CGAffineTransform.identity
          view.alpha = 1
        }
      })
    } else {
      view.recycleForCollectionKitReuse()
    }
  }

  override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds = frame.bounds
    view.center = frame.center
    if collectionView.isReloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame) {
      let offsetTime: TimeInterval = TimeInterval(frame.origin.distance(collectionView.contentOffset) / 3000)
      view.layer.transform = entryTransform
      view.alpha = 0
      UIView.animate(withDuration: 0.5, delay: offsetTime, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
        view.transform = .identity
        view.alpha = 1
      })
    }
  }

  override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    if view.center != frame.center {
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.layoutSubviews], animations: {
        view.center = frame.center
      }, completion: nil)
    }
    if view.bounds.size != frame.bounds.size {
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.layoutSubviews], animations: {
        view.bounds.size = frame.bounds.size
      }, completion: nil)
    }
    if view.alpha != 1 || view.transform != .identity {
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
        view.transform = .identity
        view.alpha = 1
      }, completion: nil)
    }
  }
}

extension CGRect {
  var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
  var bounds: CGRect {
    return CGRect(origin: .zero, size: size)
  }
  init(center: CGPoint, size: CGSize) {
    self.init(origin: center - size / 2, size: size)
  }
}

extension CGPoint {
  func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
    return CGPoint(x: self.x+dx, y: self.y+dy)
  }

  func transform(_ t: CGAffineTransform) -> CGPoint {
    return self.applying(t)
  }

  func distance(_ b: CGPoint) -> CGFloat {
    return sqrt(pow(self.x-b.x, 2)+pow(self.y-b.y, 2))
  }
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
  left.x += right.x
  left.y += right.y
}
func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func /(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x/right, y: left.y/right)
}
func *(left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x*right, y: left.y*right)
}
func *(left: CGFloat, right: CGPoint) -> CGPoint {
  return right * left
}
func *(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x*right.x, y: left.y*right.y)
}
prefix func -(point: CGPoint) -> CGPoint {
  return CGPoint.zero - point
}
func /(left: CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width/right, height: left.height/right)
}
func -(left: CGPoint, right: CGSize) -> CGPoint {
  return CGPoint(x: left.x - right.width, y: left.y - right.height)
}
