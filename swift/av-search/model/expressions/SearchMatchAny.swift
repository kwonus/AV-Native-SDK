open __abstract class SearchMatchAny { 
	public public(set) var AnyFeature: List<FeatureGeneric!>!
	public public(set) var Options: String!
	public public(set) var OptionsIdx: UInt16 = 0
	public public(set) var Hits: UInt16 = 0

	public init(_ options: String!) {
		self.AnyFeature = ()
		self.Options = options.Trim()
		self.OptionsIdx = 0
		self.Hits = 0
	}
}

