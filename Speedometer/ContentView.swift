import SwiftUI
struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @State var isMilesPerHour = true // Variable de estado para la unidad de medida
    var speed: String { return isMilesPerHour ? locationManager.speedMph : locationManager.speedKmh }
    var speedUnit: String { return isMilesPerHour ? "MPH" : "km/h" }
    var speedAccuracy: String { return isMilesPerHour ? locationManager.speedAccuracyMph : locationManager.speedAccuracyKmh }
    var averageSpeed: String { return isMilesPerHour ? locationManager.averageSpeedMph : locationManager.averageSpeedKmh }
    let plusMinus = "\u{00B1}"
    var body: some View {
        VStack {
            Text("↑ \(locationManager.degrees.formatted(.number.precision(.fractionLength(0))))º")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            Text("Average speed: \(averageSpeed) \(speedUnit)")
                .font(.title3)
            Button(action: {
                locationManager.resetValues()
            }, label: {
                Text("Reset").font(.caption2)
            })
            Spacer()
            VStack {
                Text(speed)
                    .foregroundColor(locationManager.speedColor)
                    .font(.system(size: 500, design: .rounded))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                Text(speedUnit)
                    .font(.title2)
                Text("Error: \(plusMinus)\(speedAccuracy) \(speedUnit)")
                    .font(.caption)
            }
            Spacer()
            Toggle(isOn: $isMilesPerHour) {
                Text("MPH")
            }.padding(.horizontal)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
