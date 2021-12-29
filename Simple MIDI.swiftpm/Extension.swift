import AudioKit
extension MIDIFileTrackNoteMap {
    func getNoteList() -> [MIDINoteDuration] {
        var finalNoteList = [MIDINoteDuration]()
        var eventPosition = 0.0
        var noteNumber = 0
        var noteOn = 0
        var noteOff = 0
        var velocityEvent: Int?
        var notesInProgress: [Int: (Double, Double)] = [:]
        for event in midiTrack.channelEvents {
            let data = event.data
            let eventTypeNumber = data[0]
            let eventType = event.status?.type?.description ?? "No Event"

            //Usually the third element of a note event is the velocity
            if data.count > 2 {
                velocityEvent = Int(data[2])
            }

            if noteOn == 0 {
                if eventType == "Note On" {
                    noteOn = Int(eventTypeNumber)
                }
            }
            if noteOff == 0 {
                if eventType == "Note Off" {
                    noteOff = Int(eventTypeNumber)
                }
            }

            if eventTypeNumber == noteOn {
                //A note played with a velocity of zero is the equivalent
                //of a noteOff command
                if velocityEvent == 0 {
                    eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                    noteNumber = Int(data[1])
                    if let prevPosValue = notesInProgress[noteNumber]?.0 {
                        notesInProgress[noteNumber] = (prevPosValue, eventPosition)
                        var noteTracker: MIDINoteDuration = MIDINoteDuration(
                            noteOnPosition: 0.0,
                            noteOffPosition: 0.0, noteNumber: 0)
                        if let note = notesInProgress[noteNumber] {
                            noteTracker = MIDINoteDuration(
                                noteOnPosition:
                                    note.0,
                                noteOffPosition:
                                    note.1,
                                noteNumber: noteNumber)
                        }
                        notesInProgress.removeValue(forKey: noteNumber)
                        finalNoteList.append(noteTracker)
                    }
                } else {
                    eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                    noteNumber = Int(data[1])
                    notesInProgress[noteNumber] = (eventPosition, 0.0)
                }
            }

            if eventTypeNumber == noteOff {
                eventPosition = (event.positionInBeats ?? 1.0) / Double(self.midiFile.ticksPerBeat ?? 1)
                noteNumber = Int(data[1])
                if let prevPosValue = notesInProgress[noteNumber]?.0 {
                    notesInProgress[noteNumber] = (prevPosValue, eventPosition)
                    var noteTracker: MIDINoteDuration = MIDINoteDuration(
                        noteOnPosition: 0.0,
                        noteOffPosition: 0.0,
                        noteNumber: 0)
                    if let note = notesInProgress[noteNumber] {
                        noteTracker = MIDINoteDuration(
                            noteOnPosition:
                                note.0,
                            noteOffPosition:
                                note.1,
                            noteNumber: noteNumber)
                    }
                    notesInProgress.removeValue(forKey: noteNumber)
                    finalNoteList.append(noteTracker)
                }
            }

            eventPosition = 0.0
            noteNumber = 0
            velocityEvent = nil
        }
        return finalNoteList
    }
    func getLoNote(noteList: [MIDINoteDuration]) -> Int {
        if noteList.count >= 2 {
            return (noteList.min(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
        } else {
            return 0
        }
    }
    func getHiNote(noteList: [MIDINoteDuration]) -> Int {
        if noteList.count >= 2 {
            return (noteList.max(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
        } else {
            return 0
        }
    }
    func getNoteRange(loNote: Int, hiNote: Int) -> Int {
        //Increment by 1 to properly fit the notes in the MIDI UI View
        return (hiNote - loNote) + 1
    }
}
