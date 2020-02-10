// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI

@available(iOS 13.0, *)
class ASTableViewCell: UITableViewCell
{
	var hostingController: ASHostingControllerProtocol?
	{
		didSet
		{
			let modifier = ASHostingControllerModifier(invalidateCellLayout: {
				self.shouldInvalidateLayout = true
				self.setNeedsLayout()
			})
			hostingController?.applyModifier(modifier)
		}
	}
	
	var selfSizingConfig: ASSelfSizingConfig = .init(selfSizeHorizontally: false, selfSizeVertically: true)
	var maxSizeForSelfSizing: ASOptionalSize = .none

	var invalidateLayout: (() -> Void)?
	var shouldInvalidateLayout: Bool = false

	private(set) var id: ASCollectionViewItemUniqueID?

	func setupFor(id: ASCollectionViewItemUniqueID, hostingController: ASHostingControllerProtocol?)
	{
		self.hostingController = hostingController
		self.id = id
		selectionStyle = .none
	}

	func willAppear(in vc: UIViewController?)
	{
		hostingController.map
			{
				if $0.viewController.parent != vc {
					$0.viewController.removeFromParent()
					vc?.addChild($0.viewController)
				}
				if $0.viewController.view.superview != contentView {
					$0.viewController.view.removeFromSuperview()
					contentView.subviews.forEach { $0.removeFromSuperview() }
					contentView.addSubview($0.viewController.view)
				}
				
				setNeedsLayout()
				
				vc.map { hostingController?.viewController.didMove(toParent: $0) }
		}
	}

	func didDisappear()
	{
		hostingController?.viewController.removeFromParent()
	}

	override func prepareForReuse()
	{
		hostingController = nil
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()
		hostingController?.viewController.view.frame = contentView.bounds
		if shouldInvalidateLayout
		{
			shouldInvalidateLayout = false
			invalidateLayout?()
		}
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize
	{
		guard let hc = hostingController else { return .zero }
		let size = hc.sizeThatFits(
			in: targetSize,
			maxSize: maxSizeForSelfSizing,
			selfSizeHorizontal: false,
			selfSizeVertical: selfSizingConfig.selfSizeVertically)
		return size
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize
	{
		systemLayoutSizeFitting(targetSize)
	}
}

@available(iOS 13.0, *)
class ASTableViewSupplementaryView: UITableViewHeaderFooterView
{
	var hostingController: ASHostingControllerProtocol?
	private(set) var id: Int?
	
	var selfSizingConfig: ASSelfSizingConfig = .init(selfSizeHorizontally: false, selfSizeVertically: true)
	var maxSizeForSelfSizing: ASOptionalSize = .none

	override init(reuseIdentifier: String?)
	{
		super.init(reuseIdentifier: reuseIdentifier)
		backgroundView = UIView()
	}

	required init?(coder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	func setupFor<Content: View>(id: Int, view: Content?)
	{
		self.id = id
		if let view = view
		{
			hostingController = ASHostingController<Content>(view)
		}
		else
		{
			hostingController = nil
			contentView.subviews.forEach { $0.removeFromSuperview() }
		}
	}

	func updateView<Content: View>(_ view: Content)
	{
		guard let hc = hostingController as? ASHostingController<Content> else { return }
		hc.setView(view)
	}

	func willAppear(in vc: UIViewController?)
	{
		hostingController.map
			{
				if $0.viewController.parent != vc {
					$0.viewController.removeFromParent()
					vc?.addChild($0.viewController)
				}
				if $0.viewController.view.superview != contentView {
					$0.viewController.view.removeFromSuperview()
					contentView.subviews.forEach { $0.removeFromSuperview() }
					contentView.addSubview($0.viewController.view)
				}
				
				setNeedsLayout()
				
				vc.map { hostingController?.viewController.didMove(toParent: $0) }
		}
	}

	func didDisappear()
	{
		hostingController?.viewController.removeFromParent()
	}

	override func prepareForReuse()
	{
		hostingController = nil
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()
		hostingController?.viewController.view.frame = contentView.bounds
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize
	{
		guard let hc = hostingController else { return CGSize(width: 1, height: 1) }
		let size = hc.sizeThatFits(
			in: targetSize,
			maxSize: maxSizeForSelfSizing,
			selfSizeHorizontal: false,
			selfSizeVertical: selfSizingConfig.selfSizeVertically)
		return size
	}

	override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize
	{
		systemLayoutSizeFitting(targetSize)
	}
}
