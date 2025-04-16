open class QStrongs : FeatureStrongs { 
	public init(_ search: QFind!, _ text: String!, _ parse: Parsed!, _ negate: Bool) {
		super.init(QStrongs: text, negate, search.Settings)
		var parts = text.Split(":")
		if parts.Length == 2 {
			__try {
				var lang: String! = parts[1].ToUpper().Trim()
				if lang.Length == 1 {
					var result: (UInt16!, Char) = [UInt16.Parse(parts[0].Trim()), lang[0]]
					if (result.lang == "G") || (result.lang == "H") {
						self.Strongs = result
						return
					}
				}
			}
			__catch {

			}
		}
		self.Strongs = [0, "X"]
	}
}

