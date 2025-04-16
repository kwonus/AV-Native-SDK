open __abstract class FeatureDelta : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		var entry = ObjectTable.AVXObjects.lexicon.GetRecord(writ.WordKey)
		var delta: Bool = entry.valid && !LEXICON.IsModernSameAsDisplay(entry.entry)
		var result: Bool = (self.Negate ? !delta : delta)
		return (result ? FeatureGeneric.FullMatch : FeatureGeneric.ZeroMatch)
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureDelta: text, negate, settings)

	}
}

