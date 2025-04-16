open class QHelp : QSingleton, ICommand { 
	public var Document: String!
	public var Topic: String!

	public init(_ env: QContext!, _ text: String!, _ args: Parsed![]) {
		super.init(QHelp: env, text, "help")
		if (args.Length == 1) && args[0].rule.Equals("topic") {
			self.Topic = args[0].text.ToLower()
			self.Document = ((args[0].children.Length == 1) && args[0].children[0].rule.StartsWith("doc_", StringComparison.InvariantCultureIgnoreCase) ? args[0].children[0].rule.Substring(4).ToLower() : String.Empty)
		} else {
			self.Topic = ""
			self.Document = ""
		}
	}

	open override func Execute() -> (Bool, String!) {
		return [true, "ok"]
	}
}

