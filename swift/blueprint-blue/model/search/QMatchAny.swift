open class QMatchAny : SearchMatchAny { 
	@JsonIgnore
	@YamlIgnore
	public private(set) var Search: QFind!

	public init(_ context: QFind!, _ text: String!, _ args: Parsed![]) {
		super.init(QMatchAny: text)
		if self.AnyFeature.Count > 0 {
			self.AnyFeature.Clear()
		}
		self.Search = context
		for arg in args {
			var feature = FeatureFactory.Create(context, arg.text, arg)
			if feature != nil {
				self.AnyFeature.Add(feature)
			} else {
				self.Search.AddError("A feature was identified that could not be parsed: " + text)
			}
		}
	}

	public func AsYaml() -> List<String!>! {
		return ICommand.YamlSerializer(self)
	}
}

