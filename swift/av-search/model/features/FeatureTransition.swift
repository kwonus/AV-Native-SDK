open __abstract class FeatureTransition : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var Transition: UInt8 = 0

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		if (writ.Transition && self.Transition as? UInt8) == self.Transition {
			return self.NegatableFullMatch
		}
		return self.NegatableZeroMatch
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureTransition: text, negate, settings)
		self.Transition = 0
	}
}

