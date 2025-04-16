open __abstract class FeatureFactory { 
	public static func Create(_ search: QFind!, _ text: String!, _ parse: Parsed!) -> FeatureGeneric? {
		if parse.rule.Equals("feature_option", StringComparison.InvariantCultureIgnoreCase) && (parse.children.Length >= 1) {
			for feature in parse.children {
				if feature.rule.Equals("feature", StringComparison.InvariantCultureIgnoreCase) && (parse.children.Length >= 1) {
					var positive: Bool = true
					var item: Parsed! = feature.children[0]
					if feature.rule.Equals("not", StringComparison.InvariantCultureIgnoreCase) && (feature.children.Length == 2) {
						item = feature.children[1]
						positive = false
					}
					if item.rule.Equals("item", StringComparison.InvariantCultureIgnoreCase) && (item.children.Length == 1) && (parse.children[0].children.Length == 1) {
						var type: Parsed! = item.children[0]
						switch type.rule.ToLower() {
							case "wildcard":
							case "text":
								return QLexeme(search, text, type, !positive)
							case "lemma":
								return QLemma(search, text, type, !positive)
							case "pos":
							case "pos32":
							case "pn_pos12":
								return QPartOfSpeech(search, text, type, !positive)
							case "loc":
							case "seg":
								return QTransition(search, text, type, !positive)
							case "punc":
								return QPunctuation(search, text, type, !positive)
							case "italics":
							case "jesus":
								return QDecoration(search, text, type, !positive)
							case "greek":
							case "hebrew":
								return QStrongs(search, text, type, !positive)
							case "delta":
								return QDelta(search, text, type, !positive)
							case "entities":
								return QEntity(search, text, type, !positive)
						}
					}
				}
			}
		}
		return nil
	}
}

