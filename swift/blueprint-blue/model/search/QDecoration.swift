open class QDecoration : FeatureDecoration { 
	public init(_ search: QFind!, _ text: String!, _ parse: Parsed!, _ negate: Bool) {
		super.init(QDecoration: text, negate, search.Settings)
		self.Decoration = 0
	}
}

