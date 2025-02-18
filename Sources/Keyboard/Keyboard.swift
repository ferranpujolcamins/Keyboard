import SwiftUI
import Tonic

public enum KeyboardLayout {
    case piano
    case isomorphic
    case pianoRoll
}

public struct Keyboard<Content>: View where Content: View {
    let content: (Pitch, Bool)->Content

    @StateObject var model: KeyboardModel = KeyboardModel()

    var pitchRange: ClosedRange<Pitch>
    var latching: Bool
    var noteOn: (Pitch) -> Void
    var noteOff: (Pitch) -> Void
    var layout: KeyboardLayout

    public init(pitchRange: ClosedRange<Pitch> = (Pitch(60)...Pitch(72)),
                latching: Bool = false,
                layout: KeyboardLayout = .piano,
                noteOn: @escaping (Pitch) -> Void = { _ in },
                noteOff: @escaping (Pitch) -> Void = { _ in },
                @ViewBuilder content: @escaping (Pitch, Bool)->Content) {
        self.pitchRange = pitchRange
        self.latching = latching
        self.layout = layout
        self.noteOn = noteOn
        self.noteOff = noteOff
        self.content = content
    }

    var whiteKeys: [Pitch] {
        var returnValue: [Pitch] = []
        for pitch in pitchRange {
            if pitch.note(in: .C).accidental == .natural {
                returnValue.append(pitch)
            }
        }
        return returnValue
    }

    func blackKeyExists(for pitch: Pitch) -> Bool {
        pitch.note(in: .C).accidental != .natural
    }

    public var body: some View {
        switch layout {
        case .piano:      pianoBody
        case .isomorphic: isomorphicBody
        case .pianoRoll:  pianoRollBody
        }
    }

    var isomorphicBody: some View {
        HStack(spacing: 0) {
            ForEach(pitchRange, id: \.self) { pitch in
                KeyContainer(model: model,
                             pitch: pitch,
                             latching: latching,
                             layout: .isomorphic,
                             noteOn: noteOn,
                             noteOff: noteOff,
                             content: content)
            }
        }
        .frame(minWidth: 100, minHeight: 100)
        .clipShape(Rectangle())
    }

    var pianoRollBody: some View {
        VStack(spacing: 0) {
            ForEach(pitchRange, id: \.self) { pitch in
                KeyContainer(model: model,
                             pitch: pitch,
                             latching: latching,
                             layout: .isomorphic,
                             noteOn: noteOn,
                             noteOff: noteOff,
                             content: content)
            }
        }
        .frame(minWidth: 100, minHeight: 100)
        .clipShape(Rectangle())
    }


    var pianoBody: some View {

        ZStack {
            HStack(spacing: 0) {
                ForEach(whiteKeys, id: \.self) { pitch in
                    KeyContainer(model: model,
                                 pitch: pitch,
                                 latching: latching,
                                 noteOn: noteOn,
                                 noteOff: noteOff,
                                 content: content)
                }
            }
            VStack {
                HStack(spacing: 0) {
                    ForEach(whiteKeys, id: \.self) { pitch in
                        KeyContainer(model: model,
                                     pitch: Pitch(intValue: pitch.intValue + 1),
                                     latching: latching,
                                     noteOn: noteOn,
                                     noteOff: noteOff,
                                     content: content)
                        .opacity(blackKeyExists(for: Pitch(intValue: pitch.intValue + 1)) ? 1 : 0)
                    }
                }
                Spacer()
            }
        }
        .frame(minWidth: 100, minHeight: 100)
        .clipShape(Rectangle())
    }
}

extension Keyboard where Content == KeyboardKey {

    public init(pitchRange: ClosedRange<Pitch> = (Pitch(60)...Pitch(72)),
                latching: Bool = false,
                layout: KeyboardLayout = .piano,
                noteOn: @escaping (Pitch) -> Void = { _ in },
                noteOff: @escaping (Pitch) -> Void = { _ in }) {
        self.pitchRange = pitchRange
        self.latching = latching
        self.layout = layout
        self.noteOn = noteOn
        self.noteOff = noteOff
        self.content = { KeyboardKey(pitch: $0, isActivated: $1) }
    }

}

struct Keyboard_Previews: PreviewProvider {
    static var previews: some View {
        Keyboard() { pitch, isActivated in
            KeyboardKey(pitch: pitch, isActivated: isActivated)
        }
    }
}
