open class QFragment : SearchFragment { 
	@JsonIgnore
	@YamlIgnore
	public private(set) var Search: QFind!

	public init(_ context: QFind!, _ frag: Parsed!, _ anchored: Bool = false) {
		super.init(QFragment: frag.text)
		self.Search = context
		self.Anchored = anchored
		var option = QMatchAny(context, frag.text, frag.children)
		if option != nil {
			self.AllOf.Add(option)
		} else {
			self.Search.AddError("A feature was identified that could not be parsed: " + frag.text)
		}
	}

	public func AsYaml() -> List<String!>! {
		return ICommand.YamlSerializer(self)
	}
}

