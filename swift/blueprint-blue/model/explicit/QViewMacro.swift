open class QViewMacro : QView, ICommand { 
	public init(_ env: QContext!, _ text: String!, _ arg: Parsed!) {
		super.init(QViewMacro: env, text)
		self.Tag = self.ParseLabel(arg)
	}

	private func ParseLabel(_ arg: Parsed!) -> String! {
		if arg.rule == "tag" {
			return arg.text
		}
		return String.Empty
	}

	open override func Execute() -> (Bool, String!) {
		var label: String! = self.Tag.Trim().ToLower()
		var macro: ExpandableMacro? = ExpandableMacro.Deserialize(label)
		if macro != nil {
			var html: String! = macro.AsHtml()
			return [true, html]
		}
		return [false, "Macro tag not found."]
	}
}

