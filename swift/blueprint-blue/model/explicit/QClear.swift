open class QClear : QSingleton, ICommand { 
	private var Environment: QContext!

	public public(set) var Key: String!
	public public(set) var IsValid: Bool = false

	public init(_ env: QContext!, _ text: String!, _ args: Parsed![]) {
		super.init(QClear: env, text, "clear")
		self.Environment = env
		if args.Length == 2 {
			if (args[0].rule == "clear_cmd") && args[1].rule.EndsWith("_key") {
				self.IsValid = true
				if String.IsNullOrWhiteSpace(args[1].text) {
					self.IsValid = false
					self.Key = "UNKNOWN"
				} else {
					self.Key = args[1].text
				}
				return
			} else {
				if (args[0].rule == "clear_cmd") && args[1].rule.Equals("var") {
					self.IsValid = true
					if String.IsNullOrWhiteSpace(args[1].text) {
						self.IsValid = false
						self.Key = "UNKNOWN"
					} else {
						self.Key = args[1].text
					}
					return
				}
			}
		}
		self.IsValid = false
		self.Key = String.Empty
	}

	open override func Execute() -> (Bool, String!) {
		var ok: Bool = self.Context.GlobalSettings.Clear(self)
		if ok {
			var `get`: QGet! = QGet(self.Environment, (self.Text.Equals("all", StringComparison.InvariantCultureIgnoreCase) ? String.Empty : self.Text))
			return `get`.Execute()
		}
		return [ok, (ok ? String.Empty : "Could not clear setting.")]
	}
}

