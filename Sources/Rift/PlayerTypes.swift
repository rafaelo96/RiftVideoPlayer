@preconcurrency import CoreFoundation

enum InterpolationMode: String, CaseIterable, Sendable {
    case disabled
    case rife2x
    case rife4x
    case rifeAdaptive
    case motion2Intense

    var displayName: String {
        switch self {
        case .disabled: "Off"
        case .rife2x: "RIFE 2x"
        case .rife4x: "RIFE 4x"
        case .rifeAdaptive: "Adaptive"
        case .motion2Intense: "Motion² Intenso"
        }
    }
}

struct MediaTrack: Identifiable, Equatable, Sendable {
    enum Kind: String, Sendable {
        case video
        case audio
        case subtitle
    }

    let id: String
    let kind: Kind
    let index: Int
    let label: String
    let languageCode: String?
}

struct HDRMetadata {
    let transfer: CFString
    let colorPrimaries: CFString
    let maxLuminance: Float?
    let minLuminance: Float?
    let contentLightLevel: (maxCLL: Float, maxFALL: Float)?
}
