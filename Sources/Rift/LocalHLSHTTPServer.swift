import Foundation
import Network

final class LocalHLSHTTPServer: @unchecked Sendable {
    private final class StartState: @unchecked Sendable {
        var error: Error?
    }

    private let rootURL: URL
    private let queue = DispatchQueue(label: "local.hls.http.server", qos: .userInitiated)
    private var listener: NWListener?
    private var port: NWEndpoint.Port?

    init(rootURL: URL) {
        self.rootURL = rootURL.standardizedFileURL
    }

    func start() throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        let listener = try NWListener(using: parameters, on: .any)
        let semaphore = DispatchSemaphore(value: 0)
        let startState = StartState()

        listener.stateUpdateHandler = { [weak self, weak listener] state in
            switch state {
            case .ready:
                self?.port = listener?.port
                semaphore.signal()
            case .failed(let error):
                startState.error = error
                semaphore.signal()
            default:
                break
            }
        }
        listener.newConnectionHandler = { [weak self] connection in
            self?.handle(connection)
        }
        listener.start(queue: queue)

        guard semaphore.wait(timeout: .now() + 2) == .success else {
            listener.cancel()
            throw CocoaError(.fileReadUnknown)
        }

        if let startError = startState.error {
            listener.cancel()
            throw startError
        }

        self.listener = listener
    }

    func stop() {
        listener?.cancel()
        listener = nil
        port = nil
    }

    func url(for path: String) -> URL? {
        guard let port else { return nil }
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = Int(port.rawValue)
        components.path = "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return components.url
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: queue)
        receiveRequest(on: connection, buffer: Data())
    }

    private func receiveRequest(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 16 * 1024) { [weak self] data, _, isComplete, _ in
            guard let self else {
                connection.cancel()
                return
            }

            var requestData = buffer
            if let data {
                requestData.append(data)
            }

            if requestData.range(of: Data("\r\n\r\n".utf8)) != nil || requestData.count > 64 * 1024 || isComplete {
                self.respond(to: requestData, on: connection)
            } else {
                self.receiveRequest(on: connection, buffer: requestData)
            }
        }
    }

    private func respond(to requestData: Data, on connection: NWConnection) {
        guard let request = String(data: requestData, encoding: .utf8),
              let firstLine = request.components(separatedBy: "\r\n").first else {
            send(status: "400 Bad Request", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        let parts = firstLine.split(separator: " ")
        guard parts.count >= 2, parts[0] == "GET" || parts[0] == "HEAD" else {
            send(status: "405 Method Not Allowed", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        let isHead = parts[0] == "HEAD"
        let rawPath = String(parts[1]).split(separator: "?", maxSplits: 1).first.map(String.init) ?? "/"
        let decodedPath = rawPath.removingPercentEncoding ?? rawPath
        let relativePath = decodedPath == "/" ? "master.m3u8" : String(decodedPath.drop(while: { $0 == "/" }))

        guard !relativePath.contains("..") else {
            send(status: "403 Forbidden", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        let fileURL = rootURL.appendingPathComponent(relativePath).standardizedFileURL
        guard fileURL.path.hasPrefix(rootURL.path + "/"),
              let fileData = try? Data(contentsOf: fileURL) else {
            send(status: "404 Not Found", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        let range = parseRange(from: request, fileSize: fileData.count)
        let contentType = Self.contentType(for: fileURL.pathExtension)

        if let range {
            let body = isHead ? Data() : fileData.subdata(in: range)
            send(
                status: "206 Partial Content",
                body: body,
                contentType: contentType,
                contentLength: range.count,
                extraHeaders: ["Content-Range: bytes \(range.lowerBound)-\(range.upperBound - 1)/\(fileData.count)"],
                on: connection
            )
        } else {
            send(
                status: "200 OK",
                body: isHead ? Data() : fileData,
                contentType: contentType,
                contentLength: fileData.count,
                on: connection
            )
        }
    }

    private func parseRange(from request: String, fileSize: Int) -> Range<Int>? {
        guard fileSize > 0 else { return nil }

        let lines = request.components(separatedBy: "\r\n")
        guard let rangeLine = lines.first(where: { $0.lowercased().hasPrefix("range:") }),
              let spec = rangeLine.split(separator: "=", maxSplits: 1).last else {
            return nil
        }

        let pieces = spec.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        guard pieces.count == 2 else { return nil }

        let start: Int
        let end: Int

        if pieces[0].isEmpty, let suffix = Int(pieces[1]) {
            start = max(0, fileSize - suffix)
            end = fileSize - 1
        } else if let parsedStart = Int(pieces[0]) {
            start = max(0, parsedStart)
            end = pieces[1].isEmpty ? fileSize - 1 : min(fileSize - 1, Int(pieces[1]) ?? fileSize - 1)
        } else {
            return nil
        }

        guard start <= end, start < fileSize else { return nil }
        return start..<(end + 1)
    }

    private func send(
        status: String,
        body: Data,
        contentType: String,
        contentLength: Int? = nil,
        extraHeaders: [String] = [],
        on connection: NWConnection
    ) {
        let length = contentLength ?? body.count
        var headerLines = [
            "HTTP/1.1 \(status)",
            "Content-Type: \(contentType)",
            "Content-Length: \(length)",
            "Accept-Ranges: bytes",
            "Connection: close"
        ]
        headerLines.append(contentsOf: extraHeaders)
        headerLines.append("")
        headerLines.append("")

        var response = Data(headerLines.joined(separator: "\r\n").utf8)
        response.append(body)

        connection.send(content: response, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private static func contentType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "m3u8":
            return "application/vnd.apple.mpegurl"
        case "m4s":
            return "video/iso.segment"
        case "mp4":
            return "video/mp4"
        case "ts":
            return "video/mp2t"
        default:
            return "application/octet-stream"
        }
    }
}
