open __abstract class FeatureStrongs : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var Strongs: (UInt16!, Char)

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		if (self.Strongs.lang == "H") && (writ.BCVWc.B > 39) {
			return FeatureGeneric.ZeroMatch
		}
		if (self.Strongs.lang == "G") && (writ.BCVWc.B < 40) {
			return FeatureGeneric.ZeroMatch
		}
		for n in 0 ... 4 - 1 {
			var num: UInt16! = writ.Strongs[n]
			if num == 0 {
				break
			}
			if num == self.Strongs.number {
				return self.NegatableFullMatch
			}
		}
		return self.NegatableZeroMatch
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureStrongs: text, negate, settings)
		self.Strongs = [0, "X"]
	}
}

