import Foundation
import ImageIO
import UniformTypeIdentifiers

actor ThumbnailLoader {

	// MARK: - Private Constants

	private let cache = NSCache<NSURL, NSData>()

	// MARK: - Internal Constants

	static let shared = ThumbnailLoader()

	// MARK: - Life Cycle

	init() {
		cache.totalCostLimit = 20 * 1024 * 1024
	}
}

// MARK: - Internal Methods

extension ThumbnailLoader {

	func imageData(for url: URL) async throws -> Data {
		if let cached = cache.object(forKey: url as NSURL) {
			return cached as Data
		}

		var request = URLRequest(
			url: url,
			timeoutInterval: 20
		)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		let session = URLSession(configuration: .ephemeral)

		defer { session.finishTasksAndInvalidate() }

		let (
			data,
			response
		) = try await session.data(for: request)

		guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
			let source = CGImageSourceCreateWithData(
				data as CFData,
				nil
			),
			let image = CGImageSourceCreateThumbnailAtIndex(
				source,
				Int.zero,
				[
					kCGImageSourceCreateThumbnailFromImageAlways: true,
					kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize: 360
				] as CFDictionary
			)
		else {
			throw URLError(.cannotDecodeContentData)
		}

		try Task.checkCancellation()

		let output = NSMutableData()

		guard
			let destination = CGImageDestinationCreateWithData(
				output,
				UTType.jpeg.identifier as CFString,
				1,
				nil
			)
		else {
			throw URLError(.cannotDecodeContentData)
		}

		CGImageDestinationAddImage(
			destination,
			image,
			nil
		)

		guard CGImageDestinationFinalize(destination) else {
			throw URLError(.cannotDecodeContentData)
		}

		let result = output as Data
		cache.setObject(
			result as NSData,
			forKey: url as NSURL,
			cost: result.count
		)

		return result
	}
}
