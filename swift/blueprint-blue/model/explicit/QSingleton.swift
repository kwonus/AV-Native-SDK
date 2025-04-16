open __abstract class QSingleton : QCommand, ICommand { 
	public init(_ env: QContext!, _ text: String!, _ verb: String!) {
		super.init(QSingleton: env, text, verb)

	}

	public static func Create(_ env: QContext!, _ item: Parsed!) -> QSingleton? {
		if item.rule.Equals("singleton", StringComparison.InvariantCultureIgnoreCase) {
			var commands = item.children
			if commands.Length == 1 {
				var command = commands[0]
				switch command.rule.Trim().ToLower() {
					case "help":
						return QHelp(env, command.text, command.children)
					case "control":
						return QControl(env, command.text, command.children)
					case "use":
						return QAbsorb(env, command.text, command.children)
					case "get":
						return QGet(env, command.text, command.children)
					case "set":
						return QSet(env, command.text, command.children)
					case "clear":
						return QClear(env, command.text, command.children)
					case "delete_bulk":
						return QBulk.Create(env, command.text, command)
					case "delete":
						return QDelete.Create(env, command.text, command.children)
					case "view_bulk":
						return QBulk.Create(env, command.text, command)
					case "view":
						return QView.Create(env, command.text, command.children)
				}
			}
		}
		return nil
	}

	public __abstract func Execute() -> (Bool, String!) {
	}
}

