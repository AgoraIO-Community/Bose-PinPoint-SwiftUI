//
//  ContentView.swift
//  Bose-PinPoint-SwiftUI
//
//  Created by Max Cobb on 02/12/2021.
//

import SwiftUI
import AgoraUIKit_iOS

extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}

class AgoraViewerHelper: AgoraVideoViewerDelegate {
    static var agview: AgoraViewer = {
        AgoraViewer(
            connectionData: AgoraConnectionData(
                appId: AppKeys.agoraAppId, rtcToken: AppKeys.agoraToken
            ),
            style: .floating,
            delegate: AgoraViewerHelper.delegate
        )
    }()
    static var delegate = AgoraViewerHelper()
    func extraButtons() -> [UIButton] {
        let button = UIButton()
        button.setImage(UIImage(named: "pinpoint-logo"), for: .normal)
        button.backgroundColor = .systemGreen
        button.isSelected = self.pinPointEnabled
        button.backgroundColor = self.pinPointEnabled ? .systemGreen : .systemRed
        button.addTarget(self, action: #selector(self.togglePinpoint), for: .touchUpInside)
        return [button]
    }

func registerPinPoint() {

    // Set API Credentials
    AgoraViewerHelper.agview.viewer.setExtensionProperty(
        "Bose", extension: "PinPoint", key: "apiKey", value: AppKeys.pinPointApiKey
    )
    AgoraViewerHelper.agview.viewer.setExtensionProperty(
        "Bose", extension: "PinPoint", key: "apiSecret", value: AppKeys.pinPointApiSecret
    )
}

    func joinedChannel(channel: String) {
        registerPinPoint()
    }
    var pinPointEnabled: Bool = true

    @objc func togglePinpoint(_ sender: UIButton) {
        pinPointEnabled.toggle()
        sender.backgroundColor = self.pinPointEnabled ? .systemGreen : .systemRed
        AgoraViewerHelper.agview.viewer.enableExtension(
            withVendor: "Bose", extension: "PinPoint", enabled: self.pinPointEnabled
        )
    }
}


struct ContentView: View {
    @State var joinedChannel: Bool = false

    var body: some View {
        ZStack {
            AgoraViewerHelper.agview
            if !joinedChannel {
                Button("Join Channel") {
                    self.joinChannel()
                }
            }
        }
    }

    func joinChannel() {
        self.joinedChannel = true
        AgoraViewerHelper.agview.viewer.enableExtension(
            withVendor: "Bose", extension: "PinPoint", enabled: true
        )
        AgoraViewerHelper.agview.join(
            channel: "test", with: AppKeys.agoraToken,
            as: .broadcaster
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
