open class QDelete : QSingleton, ICommand { 
	public public(set) var Tag: String!

	// macro
	public init(_ env: QContext!, _ text: String!) {
		super.init(QDelete: env, text, "delete")
		self.Tag = String.Empty
	}

	public static func Create(_ env: QContext!, _ text: String!, _ args: Parsed![]) -> QDelete! {
		if (args.Length == 2) && (args[0].rule == "delete_cmd") {
			switch args[1].rule {
				case "tag":
					return QDeleteMacro(env, text, args[1])
				case "id":
					return QDeleteHistory(env, text, args[1])
			}
		}
		return QDelete(env, text)
		//  this is a fail-safe error condition. The parse should NEVER lead us to here.
	}

	open override func Execute() -> (Bool, String!) {
		return [false, "Ambiguous target generated from parse."]
	}
}

open class QDeleteMacro : QDelete, ICommand { 
	public init(_ env: QContext!, _ text: String!, _ arg: Parsed!) {
		super.init(QDeleteMacro: env, text)
		self.Tag = arg.text
	}

	open override func Execute() -> (Bool, String!) {
		var yaml: String! = Path.Combine(QContext.MacroPath, self.Tag + ".yaml")
		if File.Exists(yaml) {
			__try {
				File.Delete(yaml)
				return [true, "Macro has been deleted."]
			}
			__catch {
				return [false, "Unable to delete macro via the tag supplied. Do you have permission?"]
			}
		}
		return [false, "Macro not found."]
	}
}

open class QDeleteHistory : QDelete, ICommand { 
	public init(_ env: QContext!, _ text: String!, _ arg: Parsed!) {
		super.init(QDeleteHistory: env, text)
		self.Tag = arg.text
	}

	open override func Execute() -> (Bool, String!) {
		var item: ExpandableHistory? = ExpandableHistory.Deserialize(self.Tag)
		if item != nil {
			var yaml: String! = item.Id.AsYamlPath()
			__try {
				File.Delete(yaml)
				return [true, "History item has been deleted."]
			}
			__catch {
				return [false, "Unable to delete history via the tag supplied. Do you have permission?"]
			}
		}
		return [false, "History tag not found."]
	}
}

