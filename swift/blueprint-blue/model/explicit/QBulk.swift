public enum BulkAction { 
	case Undefined = 0
	case View = 1
	case Delete = -1
}

open class QBulk : QSingleton, ICommand { 
	public public(set) var NumericFrom: UInt32?
	public public(set) var NumericUnto: UInt32?
	public public(set) var Action: BulkAction!

	public init(_ env: QContext!, _ text: String!, _ cmd: String!, _ action: BulkAction!) {
		super.init(QBulk: env, text, cmd)
		self.NumericFrom = nil
		self.NumericUnto = nil
		self.Action = action
	}

	public static func Create(_ env: QContext!, _ text: String!, _ arg: Parsed!) -> QBulk! {
		var action: BulkAction! = BulkAction.View
		for parse in arg.children {
			if parse.rule == "delete_arg" {
				action = BulkAction.Delete
				break
			}
		}
		for parse in arg.children {
			switch parse.rule {
				case "macros_cmd":
					return QBulkMacros(env, text, arg.children, action)
				case "history_cmd":
					return QBulkHistory(env, text, arg.children, action)
			}
		}
		return QBulk(env, text, String.Empty, BulkAction.Undefined)
		//  this is a fail-safe error condition. The parse should NEVER lead us to here.
	}

	private static func GetYMD(_ input: String!, _ y: __out Int32, _ m: __out Int32, _ d: __out Int32) -> Bool {
		var dmy: String![] = input.Split("/")
		if dmy.Length == 3 {
			__try {
				y = Int32.Parse(dmy[0])
				m = Int32.Parse(dmy[1])
				d = Int32.Parse(dmy[2])
				return true
			}
			__catch {
			}
		}
		y = 0
		m = 0
		d = 0
		return false
	}

	public func ParseDateRange(_ args: Parsed![]) {
		var y: Int32
		var m: Int32
		var d: Int32
		for arg in args {
			if (self.NumericFrom == nil) && (arg.rule == "date_from") && (arg.children.Length == 1) {
				if GetYMD(arg.children[0].text, &(y), &(m), &(d)) {
					self.NumericFrom = ((y * 100 * 100) + (m * 100) + d as? UInt32)
				}
			} else {
				if (self.NumericUnto == nil) && (arg.rule == "date_until") && (arg.children.Length == 1) {
					if GetYMD(arg.children[0].text, &(y), &(m), &(d)) {
						self.NumericUnto = ((y * 100 * 100) + (m * 100) + d as? UInt32)
					}
				}
			}
		}
	}

	open override func Execute() -> (Bool, String!) {
		return [false, "Ambiguous target generated from parse."]
	}
}

