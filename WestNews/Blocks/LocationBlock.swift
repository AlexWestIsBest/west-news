//
//  LocationBlock.swift
//  WestNews
//
//  Created by Alex Westerlund on 6/30/23.
//

import SwiftUI

struct LocationBlock: View {
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var loc = LocationManager()
    
    @State private var showPermissionDeniedAlert = false
    
    var body: some View {
        HStack {
            Spacer()
            
            if !loc.hasLocationPermissions {
                Image(systemName: "location")
                Button("Set Location") {
                    tap.selectionChanged()
                    tap.prepare()
                    loc.requestLocationUpdate(manuallyInitiated: true) {}
                }
            } else {
                Text("\(loc.subAdministrativeArea), \(loc.administrativeArea)")
                Spacer()
                Button("Refresh") {
                    tap.selectionChanged()
                    tap.prepare()
                    loc.requestLocationUpdate(manuallyInitiated: true) {}
                }
            }
            Spacer()
        }
        .padding()
        .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemGray5))
        .cornerRadius(12)
        .alert(isPresented: $loc.permissionAlert) {
            Alert(
                title: Text("Enable Location"),
                message: Text("Open Settings and enable location for this app."),
                primaryButton: .default(Text("Open Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct LocationBlock_Previews: PreviewProvider {
    static var previews: some View {
        LocationBlock()
    }
}
