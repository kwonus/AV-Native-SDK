open __abstract class FeatureLexeme : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var WordKeys: HashSet<UInt16!>!
	public public(set) var Phonetics: Dictionary<String!,Dictionary<UInt16!,UInt16!>!>!
	public public(set) var Wildcard: TypeWildcard?

	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		for lexeme in self.WordKeys {
			if lexeme == (writ.WordKey && 16383) {
				return self.NegatableFullMatch
			}
		}
		var maxSimilarity: UInt16! = 0
		for phones in self.Phonetics.Values {
			if phones.ContainsKey(writ.WordKey) {
				var similarity: UInt16! = phones[writ.WordKey]
				if similarity > maxSimilarity {
					maxSimilarity = similarity
				}
			}
		}
		return self.NegatableMatchScore(maxSimilarity)
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureLexeme: text, negate, settings)
		self.WordKeys = ()
		self.Phonetics = ()
		self.Wildcard = nil
	}
}

