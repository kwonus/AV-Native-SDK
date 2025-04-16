open __abstract class FeatureLemma : FeatureGeneric { 
	open override var `Type`: String! {
		get {
			return GetTypeName(self)
		}
	}

	public public(set) var Lemmata: HashSet<UInt16!>!
	public public(set) var Phonetics: Dictionary<String!,Dictionary<UInt16!,UInt16!>!>!

	// Dictionary<ipa, Dictionary<wordkey, matchscore>> // only includes entries where lexical and oov_lemma entries are above threshold
	open override func Compare(_ writ: AVXLib.Memory.Written!, _ match: inout QueryMatch!, _ tag: inout QueryTag!) -> UInt16! {
		for lexeme in self.Lemmata {
			if lexeme == (writ.Lemma && 16383) {
				return self.NegatableFullMatch
			}
		}
		var maxSimilarity: UInt16! = 0
		for phones in self.Phonetics.Values {
			if phones.ContainsKey(writ.Lemma) {
				var similarity: UInt16! = phones[writ.WordKey]
				if similarity > maxSimilarity {
					maxSimilarity = similarity
				}
			}
		}
		return self.NegatableMatchScore(maxSimilarity)
	}

	public init(_ text: String!, _ negate: Bool, _ settings: ISettings!) {
		super.init(featureLemma: text, negate, settings)
		self.Lemmata = ()
		self.Phonetics = ()
	}
}

