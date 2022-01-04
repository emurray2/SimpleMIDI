import SwiftUI
import AudioKit
struct ContentView: View {
    @StateObject var trackPlayer = TrackPlayer()
    @State var fileURL: URL?
    @State var fileLoading: Bool = false
    @State var isPlaying = false
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    if let fileURL = fileURL {
                        ForEach(MIDIFile(url: fileURL).tracks.indices, id: \.self) { number in
                            MIDITrackView(fileURL: $fileURL, trackNumber: number, trackWidth: geometry.size.width, trackHeight: 200.0)
                                .background(Color.primary)
                                .cornerRadius(10.0)
                        }
                    }
                }
            }
            Button { 
                isPlaying.toggle()
            } label: { 
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 50, idealWidth: 70, maxWidth: 70, minHeight: 50, idealHeight: 70, maxHeight: 70, alignment: .center)
                    .foregroundColor(.primary)
            }
            .padding()
            Button(action: {
                fileLoading.toggle()
                isPlaying = false
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
        }
        .fileImporter(isPresented: $fileLoading, 
                      allowedContentTypes: [.midi], 
                      onCompletion: { res in
            switch res {
            case .success(let url):
                fileURL = url
                if url.startAccessingSecurityScopedResource() {
                }
                trackPlayer.loadSequencerFile(fileURL: fileURL!)
            case.failure:
                print("file failed to load")
            }
        })
        .onChange(of: fileLoading, perform: { newValue in
            if newValue == true {
                trackPlayer.stop()
                trackPlayer.sequencer.rewind()
                fileURL = nil
            } else {
            }
        })
        .onChange(of: isPlaying, perform: { newValue in
            if newValue == true {
                trackPlayer.play()
            } else {
                trackPlayer.stop()
            }
        })
        .onAppear(perform: { 
            trackPlayer.startEngine()
        })
        .onDisappear(perform: { 
            fileURL!.stopAccessingSecurityScopedResource()
            trackPlayer.stop()
            trackPlayer.stopEngine()
        })
        .environmentObject(trackPlayer)
    }
}
