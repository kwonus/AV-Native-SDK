open __abstract class FeaturePunctuation : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	 let Punctuation: UInt8 = 0

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		if (writ.Punctuation && self.Punctuation as? UInt8) == self.Punctuation {
			return self.NegatableFullMatch
		}
		return self.NegatableZeroMatch
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featurePunctuation: text, negate, settings)
		self.Punctuation = 0
	}
}

