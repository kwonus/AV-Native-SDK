open class QTransition : FeatureTransition { 
	public init(_ search: QFind!, _ text: String!, _ parse: Parsed!, _ negate: Bool) {
		super.init(QTransition: text, negate, search.Settings)
		self.Transition = 0
	}
}

