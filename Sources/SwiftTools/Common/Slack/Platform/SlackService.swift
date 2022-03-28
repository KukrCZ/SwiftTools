//
//  File.swift
//
//
//  Created by Jan Halousek on 12.01.2021.
//

import Foundation

public struct SlackPayload {
    public let message: String
    public let username: String
    public let icon: String?
    public let isSuccess: Bool

    public init(message: String, username: String, icon: String? = nil, isSuccess: Bool = true) {
        self.message = message
        self.username = username
        self.icon = icon
        self.isSuccess = isSuccess
    }
}

protocol SlackService {
    func print(payload: SlackPayload) throws
}

final class SlackServiceImpl: SlackService {
    private let fastlaneService: FastlaneService
    private let configurationController: ConfigurationController

    init(fastlaneService: FastlaneService, configurationController: ConfigurationController) {
        self.fastlaneService = fastlaneService
        self.configurationController = configurationController
    }

    func print(payload: SlackPayload) throws {
        try print(message: payload.message, username: payload.username, icon: payload.icon, isSuccess: payload.isSuccess)
    }

    private func print(message: String, username: String, icon: String?, isSuccess: Bool = true) throws {
        let arguments = makeArguments(message: message, username: username, icon: icon, isSuccess: isSuccess)
        try fastlaneService.execute(arguments: arguments)
    }

    private func makeArguments(message: String, username: String, icon: String?, isSuccess: Bool) -> [String] {
        let message = message.replacingOccurrences(of: "`", with: "\\`")
        let url = configurationController.getSlackUrl()
        return [
            "run",
            "slack",
            "message:\"\(message)\"",
            "username:\"\(username)\"",
            "slack_url:\(url)",
            "default_payloads:[]",
            "channel:\"#kb-ios-dev\"",
            icon.map { "icon_url:\($0)" },
            "success:\(isSuccess ? "true" : "false")",
        ].compactMap { $0 }
    }
}
