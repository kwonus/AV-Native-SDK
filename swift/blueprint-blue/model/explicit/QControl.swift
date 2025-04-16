open class QControl : QSingleton, ICommand { 
	public static func ExtractVerbFromRule(_ args: Parsed![]) -> String! {
		if args != nil && (args.Length == 1) && args[0].rule.EndsWith("_cmd") && (args[0].rule.Length > "_cmd".Length) {
			return args[0].rule.Substring(0, args[0].rule.Length - "_cmd".Length)
		}
		return "unknown"
	}

	public init(_ env: QContext!, _ text: String!, _ args: Parsed![]) {
		super.init(QControl: env, text, ExtractVerbFromRule(args))

	}

	open override func Execute() -> (Bool, String!) {
		return [true, "ok"]
	}
}

