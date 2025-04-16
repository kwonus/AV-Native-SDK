open __abstract class FeatureEntity : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var Entity: UInt16!

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		var record: (Lexicon!, Bool) = ObjectTable.AVXObjects.lexicon.GetRecord(writ.WordKey)
		if record.valid && ((self.Entity && record.entry.Entities as? UInt16) != 0) {
			return self.NegatableFullMatch
		}
		return self.NegatableZeroMatch
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureEntity: text, negate, settings)

	}
}

