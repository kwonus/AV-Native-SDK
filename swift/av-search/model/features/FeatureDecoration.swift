open __abstract class FeatureDecoration : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var Decoration: UInt8 = 0

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		return 0
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureDecoration: text, negate, settings)
		self.Decoration = 0
	}
}

