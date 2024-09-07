//
//  DownloadManager.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/7/24.
//

import Foundation

typealias DownloadRequestID = String

struct DownloadRequest {
    let id: DownloadRequestID
    let from: URL
    let saveTo: URL
}

typealias DownloadResult = Bool
typealias DownloadResults = [DownloadRequestID: DownloadResult]

class DownloadManager {
    var session: URLSession = .shared

    init(session: URLSession) {
        self.session = session
    }

    func download(request: DownloadRequest) async -> DownloadResult {
        do {
            let (url, _) = try await session.download(
                from: request.from)
            try FileManager.default.moveItem(
                at: url, to: request.saveTo
            )
        } catch {
            return false
        }

        return true
    }

    func download(requests: [DownloadRequest]) async -> DownloadResults {
        return await withTaskGroup(
            of: (DownloadRequestID, DownloadResult).self,
            returning: DownloadResults.self
        ) { [weak self] taskGroup in
            var results = DownloadResults()

            guard let self else { return results }

            for request in requests {
                taskGroup.addTask {
                    await (request.id, self.download(request: request))
                }
            }

            for await result in taskGroup {
                results[result.0] = result.1
            }

            return results
        }
    }
}
