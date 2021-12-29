import SwiftUI
import AudioKit
struct ContentView: View {
    @State var isPlaying: Bool = false
    @State var browseFiles = false
    @State var fileURL: URL = URL(fileURLWithPath: "")
    @State var fileLoading: Bool = false
    var body: some View {
        VStack {
            if fileLoading {
                
            } else {
                GeometryReader { geometry in
                    MIDITrackView(isPlaying: $isPlaying, trackWidth: geometry.size.width, trackHeight: 200.0, fileURL: $fileURL)
                }
            }
            Button { 
                isPlaying.toggle()
            } label: { 
                Image(systemName: isPlaying ? "play.fill" : "play")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 50, idealWidth: 70, maxWidth: 70, minHeight: 50, idealHeight: 70, maxHeight: 70, alignment: .center)
                    .foregroundColor(.primary)
            }
            .padding()
            Button(action: {
                browseFiles.toggle()
                isPlaying = false
                fileLoading = true
            },
                   label: {
                VStack {
                    Image(systemName: "folder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 50, idealWidth: 70, maxWidth: 70, minHeight: 50, idealHeight: 70, maxHeight: 70, alignment: .center)
                        .foregroundColor(.primary)
                        .padding()
                    Text("Browse Files")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            })
                .fileImporter(isPresented: $browseFiles,
                              allowedContentTypes: [.midi]) { res in
                    do {
                        fileURL = try res.get()
                        if fileURL.startAccessingSecurityScopedResource() {
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    fileLoading = false
                }
        }
        .onDisappear {
            fileURL.stopAccessingSecurityScopedResource()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isPlaying = false
        }
        .onRotate { _ in
        }
    }
}
