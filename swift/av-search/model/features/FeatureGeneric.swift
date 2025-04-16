open __abstract class FeatureGeneric { 
	public __abstract let `Type`: String!
	public public(set) var Text: String!
	public public(set) var Negate: Bool = false
	public private(set) var Hits: UInt64!
	public var Settings: ISettings!

	public var NegatableFullMatch: UInt16! {
		get {
			return (!self.Negate ? FeatureGeneric.FullMatch : FeatureGeneric.ZeroMatch)
		}
	}

	public var NegatableZeroMatch: UInt16! {
		get {
			return (!self.Negate ? FeatureGeneric.ZeroMatch : FeatureGeneric.FullMatch)
		}
	}

	public static let FullMatch: UInt16! = 1000
	//  100%
	// 
	public static let ZeroMatch: UInt16! = 0

	public __abstract func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
	}

	public static func GetTypeName(_ obj: Object!) -> String! {
		var name: String! = obj.GetType().Name
		return ((name.Length >= 8) && name.StartsWith("Feature") ? name.Substring(7) : name)
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		self.Hits = 0
		self.Text = text.Trim()
		self.Negate = negate
		self.Settings = settings
		if self.Negate && self.Text.StartsWith("-") {
			self.Text = (self.Text.Length > 1 ? self.Text.Substring(1) : String.Empty)
		}
	}

	public func IncrementHits() {
		inc(self.Hits)
	}

	public func NegatableScore(_ score: UInt16!) -> UInt16! {
		if score > FeatureGeneric.FullMatch {
			return 0
		}
		return (!self.Negate ? score : (FullMatch - score as? UInt16))
	}

	public func NegatableMatchScore(_ score: UInt16!) -> UInt16! {
		if score > FeatureGeneric.FullMatch {
			return 0
		}
		return (!self.Negate ? score : (FullMatch - score as? UInt16))
	}
}

