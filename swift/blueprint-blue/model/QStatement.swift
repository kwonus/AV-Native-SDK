open class QStatement { 
	private static var PinshotDLL: PinshotLib! = PinshotLib()

	public var Text: String!
	public var IsValid: Bool = false
	public var ParseDiagnostic: String!
	public var Errors: List<String!>!
	public var Warnings: List<String!>!
	public var Disposition: Dictionary<String!,String!>!
	public var Singleton: QSingleton?
	public var Commands: QSelectionStatement?
	public private(set) var Context: QContext!

	private init() {
		self.Text = String.Empty
		self.IsValid = false
		self.ParseDiagnostic = String.Empty
		self.Errors = ()
		self.Warnings = ()
		self.Disposition = ()
		self.Singleton = nil
		self.Commands = nil
		self.Context = QContext(self)
	}

	public static func Create(_ root: RootParse?) -> QStatement! {
		if root != nil {
			var stmt: QStatement! = QStatement()
			stmt.IsValid = false
			if !String.IsNullOrEmpty(stmt.ParseDiagnostic) {
				stmt.Errors.Add("See parse diagnostic for syntax errors.")
				stmt.IsValid = false
			} else {
				if (root.result.Length == 1) && root.result[0] != nil {
					var statement = root.result[0]
					if statement.rule.Equals("statement", StringComparison.InvariantCultureIgnoreCase) && (statement.children.Length == 1) {
						var command = statement.children[0]
						if command.rule.Equals("singleton", StringComparison.InvariantCultureIgnoreCase) {
							stmt.Singleton = QSingleton.Create(stmt.Context, command)
							stmt.IsValid = stmt.Singleton != nil
							if !stmt.IsValid {
								stmt.Errors.Add("Unable to extract explicit command.")
							}
						} else {
							if command.rule.Equals("selection_statement", StringComparison.InvariantCultureIgnoreCase) {
								stmt.Commands = QSelectionStatement.Create(stmt.Context, command, stmt)
								stmt.IsValid = stmt.Commands != nil
								if (stmt.Errors.Count == 0) && !stmt.IsValid {
									stmt.Errors.Add("Unable to extract implicit commands.")
								}
							} else {
								stmt.IsValid = false
								stmt.Errors.Add("Unknown command type was encountered by parser.")
							}
						}
					}
				} else {
					stmt.IsValid = false
					if !stmt.IsValid {
						stmt.Errors.Add("Unable to identify a statement.")
					}
				}
			}
			return stmt
		}
		return QStatement() /* Property Initializers : Commands = nil, Singleton = nil, ParseDiagnostic = "", Errors = ("Unknown error: unable to perform statement parsing"), Warnings = (), IsValid = false, Text = "" */
	}

	public func AddError(_ message: String!) {
		self.Errors.Add(message)
	}

	public func AddWarning(_ message: String!) {
		self.Warnings.Add(message)
	}

	public func AddDisposition(_ type: String!, _ message: String!) {
		self.Disposition[type.ToLower()] = message
	}

	public static func Parse(_ stmt: String!, _ opaque: Bool = false, _ url: String? = nil) -> (RootParse?, QStatement?, String!) {
		var root: (RootParse?, QStatement?, String!) = [nil, nil, String.Empty]
		if url != nil && url.ToLower().StartsWith("http", StringComparison.InvariantCultureIgnoreCase) {
			var svc = PinshotSvc("http://127.0.0.1:3000/quelle")
			var task = svc.Parse(stmt)
			if task.IsCompleted {
				root.pinshot = task.Result
			}
		} else {
			root.pinshot = PinshotDLL.Parse(stmt).root
		}
		if root.pinshot != nil {
			var blue: QStatement! = QStatement.Create(root.pinshot)
			if blue.IsValid {
				root.blueprint = blue
			}
			var error = root.pinshot.error
			if !String.IsNullOrEmpty(error) {
				root.fatal = error
				Console.WriteLine(error)
			}
		}
		return root
	}
}

