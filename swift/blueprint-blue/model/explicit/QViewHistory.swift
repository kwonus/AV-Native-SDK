open class QViewHistory : QView, ICommand { 
	public init(_ env: QContext!, _ text: String!, _ arg: Parsed!) {
		super.init(QViewHistory: env, text)
		self.Tag = self.ParseTag(arg)
	}

	private func ParseTag(_ arg: Parsed!) -> String! {
		if arg.rule == "tag" {
			__try {
				return arg.text
			}
			__catch {

			}
		}
		return String.Empty
	}

	open override func Execute() -> (Bool, String!) {
		var item: ExpandableHistory? = ExpandableHistory.Deserialize(self.Tag)
		if item != nil {
			var html: String! = item.AsHtml()
			return [true, html]
		}
		return [false, "History tag not found."]
	}
}

