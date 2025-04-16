open class QWildcard : TypeWildcard { 
	private func AddParts(_ parse: Parsed!) {
		if (parse.children == nil) || (parse.children.Length != 1) {
			return
		}
		if parse.children[0].rule.Equals("nuphone", StringComparison.InvariantCultureIgnoreCase) {
			self.TermType = WildcardType.NuphoneTerm
		} else {
			if parse.children[0].rule.Equals("text", StringComparison.InvariantCultureIgnoreCase) {
				self.TermType = WildcardType.EnglishTerm
			} else {
				return
			}
		}
		var text = parse.children[0].text
		if parse.rule.Equals("term_begin", StringComparison.InvariantCultureIgnoreCase) {
			if parse.text.Contains("-") {
				self.BeginningHyphenated = text
				self.Beginning = self.Text.Replace("-", "")
			} else {
				self.Beginning = text
			}
		} else {
			if parse.rule.Equals("term_end", StringComparison.InvariantCultureIgnoreCase) {
				if parse.text.Contains("-") {
					self.EndingHyphenated = text
					self.Ending = text.Replace("-", "")
				} else {
					self.Ending = text
				}
			} else {
				if parse.rule.Equals("term_contains", StringComparison.InvariantCultureIgnoreCase) {
					if parse.text.Contains("-") {
						var normalized = text.Replace("-", "")
						self.Contains.Add(normalized)
						self.ContainsHyphenated.Add(text)
					} else {
						self.Contains.Add(text)
					}
				}
			}
		}
	}

	public init(_ text: String!, _ parse: Parsed!, _ type: WildcardType!) {
		super.init(QWildcard: text, type)
		self.Text = text.Trim()
		self.Beginning = nil
		self.Ending = nil
		self.BeginningHyphenated = nil
		self.EndingHyphenated = nil
		if parse.children != nil {
			for child in parse.children {
				self.AddParts(child)
			}
		}
	}
}

