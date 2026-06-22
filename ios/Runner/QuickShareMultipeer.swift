import Foundation
import MultipeerConnectivity
import Flutter

private struct WireHeader: Codable {
    let id: String
    let type: String
    let method: String?
    let path: String?
    let query: [String: String]?
    let status: Int?
    let contentType: String?
    let bodyLength: Int
}

final class QuickShareMultipeer: NSObject {
    static let shared = QuickShareMultipeer()
    static let serviceType = "quickshare"

    private var peerID: MCPeerID?
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var methodChannel: FlutterMethodChannel?
    private var eventSink: FlutterEventSink?

    private var pendingResponses: [String: ([String: Any]?) -> Void] = [:]
    private var discoveredPeers: [String: MCPeerID] = [:]
    private var connectedPeerId: String?

    private let queue = DispatchQueue(label: "com.quickshare.multipeer")

    func register(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.quickshare.easyfilesharing/multipeer",
            binaryMessenger: binaryMessenger
        )
        methodChannel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }

        let events = FlutterEventChannel(
            name: "com.quickshare.easyfilesharing/multipeer/events",
            binaryMessenger: binaryMessenger
        )
        events.setStreamHandler(self)
    }

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startAdvertising":
            guard let args = call.arguments as? [String: Any],
                  let peerName = args["peerName"] as? String,
                  let deviceId = args["deviceId"] as? String,
                  let deviceName = args["deviceName"] as? String else {
                result(FlutterError(code: "invalid_args", message: "Missing advertising args", details: nil))
                return
            }
            startAdvertising(peerName: peerName, deviceId: deviceId, deviceName: deviceName)
            result(nil)
        case "stopAdvertising":
            stopAdvertising()
            result(nil)
        case "startBrowsing":
            startBrowsing()
            result(nil)
        case "stopBrowsing":
            stopBrowsing()
            result(nil)
        case "connect":
            guard let args = call.arguments as? [String: Any],
                  let peerId = args["peerId"] as? String,
                  let peer = discoveredPeers[peerId] else {
                result(FlutterError(code: "peer_not_found", message: "Peer not found", details: nil))
                return
            }
            connect(to: peer, peerId: peerId)
            result(nil)
        case "disconnect":
            disconnect()
            result(nil)
        case "sendRequest":
            guard let args = call.arguments as? [String: Any],
                  let peerId = args["peerId"] as? String,
                  let method = args["method"] as? String,
                  let path = args["path"] as? String else {
                result(FlutterError(code: "invalid_args", message: "Missing request args", details: nil))
                return
            }
            let query = args["query"] as? [String: String] ?? [:]
            let bodyList = args["body"] as? [Int] ?? []
            let body = Data(bodyList.map { UInt8(clamping: $0) })
            sendRequest(peerId: peerId, method: method, path: path, query: query, body: body, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func ensurePeerID(name: String) {
        if peerID == nil {
            peerID = MCPeerID(displayName: name)
        }
    }

    private func ensureSession() {
        guard let peerID else { return }
        if session == nil {
            let newSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            newSession.delegate = self
            session = newSession
        }
    }

    private func startAdvertising(peerName: String, deviceId: String, deviceName: String) {
        stopAdvertising()
        ensurePeerID(name: peerName)
        ensureSession()
        guard let peerID, let session else { return }

        let info = [
            "id": deviceId,
            "name": deviceName,
            "v": "2",
        ]
        let adv = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: info, serviceType: Self.serviceType)
        adv.delegate = self
        adv.startAdvertisingPeer()
        advertiser = adv
    }

    private func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    private func startBrowsing() {
        stopBrowsing()
        ensurePeerID(name: UIDevice.current.name)
        ensureSession()
        guard let peerID, let session else { return }

        let br = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        br.delegate = self
        br.startBrowsingForPeers()
        browser = br
    }

    private func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        discoveredPeers.removeAll()
    }

    private func connect(to peer: MCPeerID, peerId: String) {
        guard let browser, let session else { return }
        connectedPeerId = peerId
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }

    private func disconnect() {
        session?.disconnect()
        connectedPeerId = nil
    }

    private func sendRequest(
        peerId: String,
        method: String,
        path: String,
        query: [String: String],
        body: Data,
        result: @escaping FlutterResult
    ) {
        guard let session else {
            result(FlutterError(code: "no_session", message: "No multipeer session", details: nil))
            return
        }

        let peer = discoveredPeers[peerId]
        let connected = session.connectedPeers.first(where: { $0.displayName == peer?.displayName }) ?? session.connectedPeers.first
        guard let target = connected else {
            result(FlutterError(code: "not_connected", message: "Peer is not connected", details: nil))
            return
        }

        let requestId = UUID().uuidString
        let header = WireHeader(
            id: requestId,
            type: "req",
            method: method,
            path: path,
            query: query,
            status: nil,
            contentType: nil,
            bodyLength: body.count
        )

        guard let packet = encodePacket(header: header, body: body) else {
            result(FlutterError(code: "encode_error", message: "Failed to encode request", details: nil))
            return
        }

        pendingResponses[requestId] = { response in
            result(response)
        }

        queue.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self else { return }
            let timedOut = self.pendingResponses.removeValue(forKey: requestId)
            timedOut?(["statusCode": 504, "body": [UInt8](), "contentType": NSNull()])
        }

        do {
            try session.send(packet, toPeers: [target], with: .reliable)
        } catch {
            pendingResponses.removeValue(forKey: requestId)
            result(FlutterError(code: "send_failed", message: error.localizedDescription, details: nil))
        }
    }

    private func encodePacket(header: WireHeader, body: Data) -> Data? {
        guard let headerData = try? JSONEncoder().encode(header) else { return nil }
        var packet = Data()
        var headerLength = UInt32(headerData.count).bigEndian
        var bodyLength = UInt32(body.count).bigEndian
        packet.append(Data(bytes: &headerLength, count: 4))
        packet.append(Data(bytes: &bodyLength, count: 4))
        packet.append(headerData)
        packet.append(body)
        return packet
    }

    private func decodePacket(_ data: Data) -> (WireHeader, Data)? {
        guard data.count >= 8 else { return nil }
        let headerLength = Int(data.subdata(in: 0..<4).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        let bodyLength = Int(data.subdata(in: 4..<8).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        let headerEnd = 8 + headerLength
        guard data.count >= headerEnd + bodyLength else { return nil }
        let headerData = data.subdata(in: 8..<headerEnd)
        let body = data.subdata(in: headerEnd..<(headerEnd + bodyLength))
        guard let header = try? JSONDecoder().decode(WireHeader.self, from: headerData) else { return nil }
        return (header, body)
    }

    private func handleIncomingPacket(_ data: Data, from peer: MCPeerID) {
        guard let (header, body) = decodePacket(data) else { return }

        if header.type == "res" {
            let callback = pendingResponses.removeValue(forKey: header.id)
            let response: [String: Any] = [
                "statusCode": header.status ?? 500,
                "contentType": header.contentType as Any,
                "body": [UInt8](body),
            ]
            callback?(response)
            return
        }

        guard header.type == "req" else { return }
        let args: [String: Any] = [
            "method": header.method ?? "GET",
            "path": header.path ?? "/",
            "query": header.query ?? [:],
            "body": [UInt8](body),
        ]

        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod("handleRequest", arguments: args) { result in
                guard let self else { return }
                let responseMap = result as? [String: Any]
                let status = responseMap?["statusCode"] as? Int ?? 500
                let contentType = responseMap?["contentType"] as? String
                let bodyList = responseMap?["body"] as? [Int] ?? []
                let responseBody = Data(bodyList.map { UInt8(clamping: $0) })
                let responseHeader = WireHeader(
                    id: header.id,
                    type: "res",
                    method: nil,
                    path: nil,
                    query: nil,
                    status: status,
                    contentType: contentType,
                    bodyLength: responseBody.count
                )
                guard let packet = self.encodePacket(header: responseHeader, body: responseBody),
                      let session = self.session else { return }
                try? session.send(packet, toPeers: [peer], with: .reliable)
            }
        }
    }

    private func emit(type: String, peerId: String, deviceName: String = "", deviceId: String = "") {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?([
                "type": type,
                "peerId": peerId,
                "deviceName": deviceName,
                "deviceId": deviceId,
            ])
        }
    }
}

extension QuickShareMultipeer: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

extension QuickShareMultipeer: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }
}

extension QuickShareMultipeer: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let peerId = peerID.displayName
        discoveredPeers[peerId] = peerID
        emit(
            type: "peerFound",
            peerId: peerId,
            deviceName: info?["name"] ?? peerID.displayName,
            deviceId: info?["id"] ?? peerId
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let peerId = peerID.displayName
        discoveredPeers.removeValue(forKey: peerId)
        emit(type: "peerLost", peerId: peerId)
    }
}

extension QuickShareMultipeer: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let peerId = peerID.displayName
        switch state {
        case .connected:
            emit(type: "peerConnected", peerId: peerId)
        case .notConnected:
            emit(type: "peerDisconnected", peerId: peerId)
        default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        handleIncomingPacket(data, from: peerID)
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}
