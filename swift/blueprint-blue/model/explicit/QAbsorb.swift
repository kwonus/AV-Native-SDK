open class QAbsorb : QSingleton, ICommand { 
	public private(set) var Tag: String!
	public private(set) var Environment: QContext!

	public init(_ env: QContext!, _ text: String!, _ args: Parsed![]) {
		super.init(QAbsorb: env, text, "use")
		self.Tag = String.Empty
		self.Environment = env
		if String.IsNullOrWhiteSpace(text) {
			return
		}
		if (args.Length == 2) && (args[0].rule == "use_cmd") {
			self.Tag = args[1].text
		}
	}

	open override func Execute() -> (Bool, String!) {
		var expandable: ExpandableInvocation? = ExpandableHistory.Deserialize(tag: self.Tag)
		if expandable == nil {
			expandable = ExpandableMacro.Deserialize(tag: self.Tag)
		}
		if expandable != nil {
			var settings = expandable.Settings
			for setting in expandable.Settings {
				var assignment: QAssign! = QAssign.CreateAssignment(self.Environment, self.Text, setting.Key, setting.Value)
				self.Environment.GlobalSettings.Assign(assignment)
			}
			self.Environment.GlobalSettings.Update()
			var `get`: QGet! = QGet(self.Environment, self.Text)
			return `get`.Execute()
		}
		return [false, "Hashtag not found."]
	}
}

