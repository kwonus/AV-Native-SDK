public protocol ISettings {
    let SearchAsAV: Bool { get }
    let SearchAsAVX: Bool { get }
    let RenderAsAV: Bool { get }
    let RenderAsAVX: Bool { get }
    let RenderingFormat: Int32 { get }
    let SearchSimilarity: (UInt8, UInt8) { get }
    let SearchSpan: UInt16 { get }

    //  0 to 999
    //
    public static let Formatting_TEXT: Int32 = 0
    public static let Formatting_MD: Int32 = 1
    public static let Formatting_HTML: Int32 = 2
    public static let Formatting_YAML: Int32 = 3
    public static let Formatting_JSON: Int32 = 4
    public static let Lexion_UNDEFINED: Int32 = 0
    public static let Lexion_AV: Int32 = 1
    public static let Lexion_AVX: Int32 = 2
    public static let Lexion_BOTH: Int32 = 3
}

public protocol ISetting {
    let SettingName: String! { get }
}