open class QBulkMacros : QBulk, ICommand { 
	public private(set) var Label: String?
	public private(set) var Wildcard: String?

	// macro
	public init(_ env: QContext!, _ text: String!, _ args: Parsed![], _ action: BulkAction!) {
		super.init(QBulkMacros: env, text, "macros", action)
		self.Label = nil
		self.Wildcard = nil
		self.ParseDateRange(args)
		self.ParseWildcard(args)
	}

	public func ParseWildcard(_ args: Parsed![]) {
		for arg in args {
			if arg.rule == "wildcard" {
				self.Wildcard = arg.text
				break
			}
		}
	}

	open override func Execute() -> (Bool, String!) {
		var macros: IEnumerable<ExpandableInvocation!>!
		if self.Wildcard != nil {
			macros = QContext.GetMacros(self.Wildcard)
		} else {
			macros = QContext.GetMacros(self.NumericFrom, self.NumericUnto)
		}
		var html: String! = (macros != nil ? ExpandableInvocation.AsBulkHtml(macros, ExpandableMacro.self) : String.Empty)
		return [true, html]
	}
}

