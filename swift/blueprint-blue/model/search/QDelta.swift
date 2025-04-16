open class QDelta : FeatureDelta { 
	public init(_ search: QFind!, _ text: String!, _ parse: Parsed!, _ negate: Bool) {
		super.init(QDelta: text, negate, search.Settings)

	}
}

