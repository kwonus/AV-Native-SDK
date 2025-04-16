open class QGet : QSingleton, ICommand { 
	public var Key: String!

	internal init(_ env: QContext!, _ text: String!) {
		super.init(QGet: env, text, "get")
		self.Key = String.Empty
	}

	public init(_ env: QContext!, _ text: String!, _ args: Parsed![]) {
		super.init(QGet: env, text, "get")
		switch args[0].children.Length {
			case 2:
				if args[0].rule.EndsWith("_get") {
					if args[0].children[1].rule.EndsWith("_key") {
						self.Key = args[0].children[1].text.ToLower()
						return
					}
				}
			case 1:
				if args[0].children[0].rule.EndsWith("_key") {
					self.Key = args[0].children[0].text.ToLower()
					return
				}
		}
		self.Key = String.Empty
	}

	open override func Execute() -> (Bool, String!) {
		var result: String! = self.Context.GlobalSettings.Get(self, Model.Implicit.QFormat.QFormatVal.MD)
		if !String.IsNullOrEmpty(result) {
			Console.WriteLine(result)
		}
		return [!String.IsNullOrEmpty(result), result]
	}
}

