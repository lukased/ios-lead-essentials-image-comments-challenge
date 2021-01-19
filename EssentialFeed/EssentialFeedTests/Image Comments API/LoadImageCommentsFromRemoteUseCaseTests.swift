//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 19/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader{
	let client: HTTPClient
	let url: URL
	
	init(client: HTTPClient, url: URL){
		self.client = client
		self.url = url
	}
	
	func load(completion: @escaping (Error?) -> Void){
		client.get(from: url){ result in
			switch result{
			case .failure(let error):
				completion(error)
			default:
				break
			}
		}
	}
}

class LoadImageCommentsFromRemoteUseCaseTests:XCTestCase{
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://comments-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load{ _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://comments-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load{ _ in }
		sut.load{ _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		let exp = expectation(description: "Wait for load completion")
		var receivedError:Error?
		
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}
		
		client.complete(with: anyNSError())
		
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertNotNil(receivedError)
	}
	
	
	
	// MARK: Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (RemoteImageCommentsLoader, HTTPClientSpy){
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}
}

