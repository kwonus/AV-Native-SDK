open class QBulkHistory : QBulk, ICommand { 
	public init(_ env: QContext!, _ text: String!, _ args: Parsed![], _ action: BulkAction!) {
		super.init(QBulkHistory: env, text, "history", action)
		self.ParseDateRange(args)
	}

	open override func Execute() -> (Bool, String!) {
		var history: IEnumerable<ExpandableInvocation!>!
		history = QContext.GetHistory(self.NumericFrom, self.NumericUnto)
		var html: String! = (history != nil ? ExpandableInvocation.AsBulkHtml(history, ExpandableHistory.self) : String.Empty)
		return [true, html]
	}
}

