open class QPunctuation : FeaturePunctuation { 
	public private(set) var Punctuation: UInt8 = 0

	public init(_ search: QFind!, _ text: String!, _ parse: Parsed!, _ negate: Bool) {
		super.init(QPunctuation: text, negate, search.Settings)
		self.Punctuation = 0
	}
}

