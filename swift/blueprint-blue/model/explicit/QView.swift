open class QView : QSingleton, ICommand { 
	public public(set) var Tag: String!

	public init(_ env: QContext!, _ text: String!) {
		super.init(QView: env, text, "view")

	}

	public static func Create(_ env: QContext!, _ text: String!, _ args: Parsed![]) -> QView! {
		if args.Length == 2 {
			switch args[1].rule {
				case "tag":
					return QViewMacro(env, text, args[1])
				case "id":
					return QViewHistory(env, text, args[1])
			}
		}
		return QView(env, text)
		//  this is a fail-safe error condition. The parse should NEVER lead us to here.
	}

	open override func Execute() -> (Bool, String!) {
		return [false, "Ambiguous target generated from parse."]
	}
}

