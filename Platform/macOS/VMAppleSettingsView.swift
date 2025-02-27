//
// Copyright © 2021 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

struct VMAppleSettingsView: View {
    @ObservedObject var config: UTMAppleConfiguration
    
    @State private var infoActive: Bool = true
    
    private var hasVenturaFeatures: Bool {
        if #available(macOS 13, *) {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        if #available(macOS 13, *) {
            // SwiftUI bug: trick to have first item selected doesn't always work
            NavigationLink(destination: VMConfigInfoView(config: $config.information).scrollable()) {
                Label("Information", systemImage: "info.circle")
            }
        } else {
            NavigationLink(destination: VMConfigInfoView(config: $config.information).scrollable(), isActive: $infoActive) {
                Label("Information", systemImage: "info.circle")
            }
        }
        NavigationLink(destination: VMConfigAppleSystemView(config: $config.system).scrollable()) {
            Label("System", systemImage: "cpu")
        }
        NavigationLink(destination: VMConfigAppleBootView(config: $config.system).scrollable()) {
            Label("Boot", systemImage: "power")
        }
        NavigationLink(destination: VMConfigAppleVirtualizationView(config: $config.virtualization, operatingSystem: config.system.boot.operatingSystem).scrollable()) {
            Label("Virtualization", systemImage: "wrench.and.screwdriver")
        }
        if #available(macOS 12, *) {
            if hasVenturaFeatures || config.system.boot.operatingSystem == .linux {
                NavigationLink(destination: VMConfigAppleSharingView(config: config).scrollable()) {
                    Label("Sharing", systemImage: "person.crop.circle")
                }
            }
        }
        Section(header: Text("Devices")) {
            if #available(macOS 12, *) {
                if hasVenturaFeatures || config.system.boot.operatingSystem == .macOS {
                    ForEach($config.displays) { $display in
                        NavigationLink(destination: VMConfigAppleDisplayView(config: $display).scrollable()) {
                            Label("Display", systemImage: "rectangle.on.rectangle")
                        }.contextMenu {
                            DestructiveButton("Remove") {
                                config.displays.removeAll(where: { $0.id == display.id })
                            }
                        }
                    }
                }
            }
            ForEach($config.serials) { $serial in
                NavigationLink(destination: VMConfigAppleSerialView(config: $serial).scrollable()) {
                    Label("Serial", systemImage: "rectangle.connected.to.line.below")
                }.contextMenu {
                    DestructiveButton("Remove") {
                        config.serials.removeAll(where: { $0.id == serial.id })
                    }
                }
            }
            ForEach($config.networks) { $network in
                NavigationLink(destination: VMConfigAppleNetworkingView(config: $network).scrollable()) {
                    Label("Network", systemImage: "network")
                }.contextMenu {
                    DestructiveButton("Remove") {
                        config.networks.removeAll(where: { $0.id == network.id })
                    }
                }
            }
            VMAppleSettingsAddDeviceMenuView(config: config)
        }
        Section(header: Text("Drives")) {
            VMDrivesSettingsView(drives: $config.drives, template: UTMAppleConfigurationDrive(newSize: 10240))
        }
    }
}

struct VMAppleSettingsView_Previews: PreviewProvider {
    @StateObject static var config = UTMAppleConfiguration()
    static var previews: some View {
        VMAppleSettingsView(config: config)
    }
}
