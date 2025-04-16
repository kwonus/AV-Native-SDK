open __abstract class FeaturePartOfSpeech : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var PnPos12: (UInt16!, UInt16!)
	public public(set) var Pos32: UInt32!

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		if (self.Pos32 != 0) && (self.Pos32 == writ.POS32) {
			return self.NegatableFullMatch
		}
		if (self.PnPos12.value != 0) && (self.PnPos12.mask != 0) && (self.PnPos12.value == (writ.pnPOS12 && self.PnPos12.mask as? UInt16)) {
			return self.NegatableFullMatch
		}
		return self.NegatableZeroMatch
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featurePartOfSpeech: text, negate, settings)
		self.PnPos12 = [0, 0]
		self.Pos32 = 0
	}
}

