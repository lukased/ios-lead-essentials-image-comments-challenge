//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsControllerDelegate {
	func didRequestImageCommentsRefresh()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
	
	private(set) public var errorView: ErrorView = ErrorView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
	
	public var delegate: ImageCommentsControllerDelegate?
	
	var loaderTask: ImageCommentsLoaderTask?
	
	private var imageComments = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		
		tableView.tableHeaderView = errorView
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}
	
	@objc private func refresh() {
		self.delegate?.didRequestImageCommentsRefresh()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		imageComments = viewModel.imageComments
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		
		self.refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView.message = viewModel.message
	}
	
	// MARK: - Table View
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.configure(imageComment: imageComments[indexPath.row])
		
		return cell
	}
}
