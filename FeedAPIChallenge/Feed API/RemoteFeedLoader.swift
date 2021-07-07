//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200, let feedItemsRoot = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(feedItemsRoot.feedImages))
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [FeedItem]

	var feedImages: [FeedImage] {
		items.map({ FeedImage(id: $0.uuid, description: $0.description, location: $0.location, url: $0.imageURL) })
	}
}

private struct FeedItem: Decodable {
	let uuid: UUID
	let description: String?
	let location: String?
	let imageURL: URL
}

extension FeedItem {
	enum CodingKeys: String, CodingKey {
		case uuid = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case imageURL = "image_url"
	}
}
