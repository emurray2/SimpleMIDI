// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKitUI/
import AudioKit
import SwiftUI

struct NoteGroup: UIViewRepresentable {
    @Binding var isPlaying: Bool
    let sequencer: AppleSequencer
    let sampler: MIDISampler
    let noteMap: MIDIFileTrackNoteMap
    let trackHeight: CGFloat
    let noteZoom: CGFloat

    func makeUIView(context: Context) -> some UIView {
        let length = CGFloat(noteMap.endOfTrack) * noteZoom
        let view = UIView(frame: CGRect(x: 0, y: 0, width: length, height: trackHeight))
        populateViewNotes(view, context: context)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isPlaying {
            uiView.frame.origin.x = 0.0
            var tempo = 0.0
            engine.output = Reverb(sampler, dryWetMix: 0.2)
            sequencer.setGlobalMIDIOutput(sampler.midiIn)
            do {
                try sampler.loadSoundFont("UprightPianoKW-20190703", preset: 0, bank: 0)
                try engine.start()
            } catch let err {
                print(err.localizedDescription)
            }
            if sequencer.allTempoEvents.isNotEmpty {
                tempo = sequencer.allTempoEvents[0].1
            } else {
                tempo = sequencer.tempo
            }
            setupTimer(uiView, tempo: &tempo)
        }
    }

    func scrollNotes(_ uiView: UIView, tempo: UnsafeMutablePointer<Double>, timer: Timer) {
        uiView.frame.origin.x -= 1
        if tempo.pointee != sequencer.tempo && sequencer.allTempoEvents.count > 1 {
            timer.invalidate()
            var tempo = sequencer.tempo
            setupTimer(uiView, tempo: &tempo)
        }
    }
    func populateViewNotes(_ uiView: UIView, context: Context) {
        let noteList = noteMap.getNoteList()
        let low = noteMap.getLoNote(noteList: noteList)
        let high = noteMap.getHiNote(noteList: noteList)
        let range = noteMap.getNoteRange(loNote: low, hiNote: high)
        let noteh = trackHeight / CGFloat(range)
        let maxh = trackHeight - noteh
        for note in noteList {
            let noteNumber = note.noteNumber - low
            let noteStart = note.noteStartTime
            let noteDuration = note.noteDuration
            let noteLength = CGFloat(noteDuration) * noteZoom
            let notePosition = CGFloat(noteStart) * noteZoom
            let noteLevel = (maxh - (CGFloat(noteNumber) * noteh))
            let singleNoteRect = CGRect(x: notePosition, y: noteLevel, width: noteLength, height: noteh)
            let singleNoteView = UIView(frame: singleNoteRect)
            singleNoteView.backgroundColor = UIColor.secondarySystemBackground
            singleNoteView.layer.cornerRadius = noteh * 0.5
            uiView.addSubview(singleNoteView)
        }
    }
    func setupTimer(_ uiView: UIView, tempo: UnsafeMutablePointer<Double>) {
        let base: Double = (20 + (8.0 / 10.0) + (1.0 / 30.0))
        let inverse: Double = 1.0 / base
        let multiplier: Double = inverse * 60 * (10_000 / Double(noteZoom))
        sequencer.play()
        var tempo = tempo.pointee
        let scrollTimer = Timer.scheduledTimer(
            withTimeInterval: multiplier * (1/tempo), repeats: true) { timer in
                scrollNotes(uiView, tempo: &tempo, timer: timer)
            if !isPlaying {
                sequencer.stop()
                timer.invalidate()
            }
        }
        RunLoop.main.add(scrollTimer, forMode: .common)
    }
}
/// MIDI track UI similar to the one in your DAW
public struct MIDITrackView: View {
    @Binding var isPlaying: Bool
    let trackWidth: CGFloat
    let trackHeight: CGFloat
    @Binding var fileURL: URL
    /// Sets the zoom level of the track
    public var noteZoom: CGFloat = 50_000

    public var body: some View {
        VStack {
            ScrollView {
                let sequencer = AppleSequencer(fromURL: fileURL)
                let sampler = MIDISampler()
                ForEach(MIDIFile(url: fileURL).tracks.indices, id: \.self) { number in
                    let noteMap = MIDIFileTrackNoteMap(midiFile: MIDIFile(url: fileURL), trackNumber: number)
                    NoteGroup(isPlaying: $isPlaying,
                              sequencer: sequencer,
                              sampler: sampler,
                              noteMap: noteMap,
                              trackHeight: trackHeight,
                              noteZoom: noteZoom)
                        .frame(width: trackWidth, height: trackHeight, alignment: .center)
                        .background(Color.primary)
                        .cornerRadius(10)
                }
            }
        }
    }
}
