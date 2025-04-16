//  AVX-Quelle specification: 2.0.3.701
// 

internal enum SIMILARITY { 
	case NONE = 0
	case FUZZY_MIN = 33
	case FUZZY_MAX = 99
	case EXACT = 100
}

open class QSpan : ISetting { 
	public static var Name: String! = QSpan.self.Name.Substring(1).ToLower()

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public var Value: UInt16 = 0

	public static let VERSE: UInt16 = 0
	//  zero means verse-scope
	// 
	public static let DEFAULT: UInt16 = VERSE

	public init() {
		self.Value = VERSE
	}

	public init(_ span: UInt16!) {
		self.Update(span)
	}

	public init(_ span: String!) {
		var ispan: UInt16! = FromString(span)
		self.Update(ispan)
	}

	public static func FromString(_ val: String!) -> UInt16! {
		var test: String! = val.Trim()
		if test.Equals("verse", StringComparison.InvariantCultureIgnoreCase) {
			return VERSE
		} else {
			__try {
				return UInt16.Parse(val)
			}
			__catch {

			}
		}
		return VERSE
	}

	open override func ToString() -> String! {
		return (self.Value == 0 ? "verse" : self.Value.ToString())
	}

	public func AsYaml() -> String! {
		return "span: " + ToString()
	}

	internal func Update(_ span: UInt16!) {
		self.Value = (span <= 999 ? span : (999 as? UInt16))
	}
}

open class QSimilarity : ISetting { 
	public static var Name: String! = QSimilarity.self.Name.Substring(1).ToLower()

	public var Word: QSimilarityWord!
	public var Lemma: QSimilarityLemma!

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public static var DEFAULT: (UInt8, UInt8) {
		get {
			return [QSimilarityWord.DEFAULT, QSimilarityLemma.DEFAULT]
		}
	}

	public var Value: (UInt8, UInt8) {
		get {
			return [self.Word.Value, self.Lemma.Value]
		}
	}

	public init(_ word: UInt8? = nil, _ lemma: UInt8? = nil, _ baseline: ISettings? = nil) {
		self.Word = (word != nil ? QSimilarityWord(word.Value, baseline) : QSimilarityWord())
		self.Lemma = (lemma != nil ? QSimilarityLemma(lemma.Value, baseline) : QSimilarityLemma())
	}

	private init(_ word: QSimilarityWord!, _ lemma: QSimilarityLemma!) {
		self.Word = word
		self.Lemma = lemma
	}

	public static func Create(_ word: QSimilarityWord?, _ lemma: QSimilarityLemma?) -> QSimilarity! {
		return ((word != nil ? word : QSimilarityWord()), (lemma != nil ? lemma : QSimilarityLemma()))
	}

	public init(_ val: String!, _ baseline: ISettings? = nil) {
		self.Word = QSimilarityWord(val, baseline)
		self.Lemma = QSimilarityLemma(val, baseline)
	}

	public init(_ sword: String!, _ slemma: String!, _ baseline: ISettings? = nil) {
		self.Word = QSimilarityWord(sword, baseline)
		self.Lemma = QSimilarityLemma(slemma, baseline)
	}

	public static func SimilarityFromString(_ val: String!, _ baseline: ISettings? = nil) -> UInt8 {
		var result: UInt8
		if val.Equals("off", StringComparison.InvariantCultureIgnoreCase) {
			return (0 as? UInt8)
		}
		__try {
			result = (val.EndsWith("%") && (val.Length >= 2) ? (UInt16.Parse(val.Substring(0, val.Length - 1)) as? UInt8) : (UInt16.Parse(val) as? UInt8))
			return ((result >= 0) && (result <= 100) ? result : DEFAULT.word)
		}
		__catch {
			return DEFAULT.word
		}
	}

	public static func SimilarityToString(_ similarity: UInt8) -> String! {
		var result: String!
		if similarity <= (SIMILARITY.FUZZY_MIN as? UInt8) {
			result = "off"
		} else {
			if similarity >= (SIMILARITY.EXACT as? UInt8) {
				result = "100%"
			} else {
				result = similarity.ToString() + "%"
			}
		}
		return result
	}

	open override func ToString() -> String! {
		var result: String! = "word: " + self.Value.word.ToString() + ", " + "lemma: " + self.Value.lemma.ToString()
		return result
	}

	public func AsYaml() -> String! {
		var yaml: String! = self.Word.AsYaml() + "\n" + self.Lemma.AsYaml()
		return yaml
	}
}

open class QSimilarityWord : ISetting { 
	public static var Name: String! = "similarity.word"

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public static var DEFAULT: UInt8 {
		get {
			return (SIMILARITY.NONE as? UInt8)
		}
	}

	public private(set) var Value: UInt8 = 0

	public init() {
		Value = DEFAULT
	}

	public init(_ val: UInt8, _ baseline: ISettings? = nil) {
		self.Value = ((val >= (SIMILARITY.FUZZY_MIN as? UInt8)) && (val <= (SIMILARITY.EXACT as? UInt8)) ? val : (baseline != nil ? baseline.SearchSimilarity.word : DEFAULT))
	}

	public init(_ val: String!, _ baseline: ISettings? = nil) {
		var result = QSimilarity.SimilarityFromString(val, baseline)
		self.Value = ((result >= (SIMILARITY.FUZZY_MIN as? UInt8)) && (result <= (SIMILARITY.EXACT as? UInt8)) ? result : (baseline != nil ? baseline.SearchSimilarity.word : DEFAULT))
	}

	open override func ToString() -> String! {
		var result: String! = QSimilarity.SimilarityToString(self.Value)
		return result
	}

	public func AsYaml() -> String! {
		return QSimilarityWord.Name + ": " + self.ToString()
	}
}

open class QSimilarityLemma : ISetting { 
	public static var Name: String! = "similarity.lemma"

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public static var DEFAULT: UInt8 {
		get {
			return (SIMILARITY.NONE as? UInt8)
		}
	}

	public private(set) var Value: UInt8 = 0

	public init() {
		Value = DEFAULT
	}

	public init(_ val: UInt8, _ baseline: ISettings? = nil) {
		self.Value = ((val >= (SIMILARITY.FUZZY_MIN as? UInt8)) && (val <= (SIMILARITY.EXACT as? UInt8)) ? val : (baseline != nil ? baseline.SearchSimilarity.word : DEFAULT))
	}

	public init(_ val: String!, _ baseline: ISettings? = nil) {
		var result = QSimilarity.SimilarityFromString(val, baseline)
		self.Value = ((result >= (SIMILARITY.FUZZY_MIN as? UInt8)) && (result <= (SIMILARITY.EXACT as? UInt8)) ? result : (baseline != nil ? baseline.SearchSimilarity.word : DEFAULT))
	}

	open override func ToString() -> String! {
		var result: String! = QSimilarity.SimilarityToString(self.Value)
		return result
	}

	public func AsYaml() -> String! {
		return "similarity.lemma: " + self.ToString()
	}
}

open class QLexicon : ISetting { 
	public static var Name: String! = QLexicon.self.Name.Substring(8).ToLower()
	public static var DEFAULT: (QLexiconVal!, QLexiconVal!) = [QLexicalDomain.DEFAULT, QLexicalDisplay.DEFAULT]

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public var Domain: QLexicalDomain!
	public var Render: QLexicalDisplay!

	@YamlIgnore
	public var Value: (QLexiconVal!, QLexiconVal!) {
		get {
			return [self.Domain.Value, self.Render.Value]
		}
	}

	public init() {
		self.Domain = ()
		self.Render = ()
	}

	public init(_ val: QLexiconVal!) {
		self.Domain = (val)
		self.Render = (val)
	}

	public init(_ val: String!) {
		self.Domain = (val)
		self.Render = (val)
	}

	public init(_ search: QLexiconVal!, _ render: QLexiconVal!) {
		self.Domain = (search)
		self.Render = (render)
	}

	public init(_ search: String!, _ render: String!) {
		self.Domain = (search)
		self.Render = (render)
	}

	public static func FromString(_ val: String!) -> QLexiconVal! {
		switch val.Trim().ToUpper() {
			case "KJV":
			case "AV":
				return QLexiconVal.AV
			case "MODERN":
			case "MOD":
			case "AVX":
				return QLexiconVal.AVX
			case "BOTH":
			case "DUAL":
				return QLexiconVal.BOTH
			default:
				return QLexiconVal.UNDEFINED
		}
	}

	public static func ToString(_ val: QLexiconVal!) -> String! {
		switch val {
			case QLexiconVal.AV:
				return "av"
			case QLexiconVal.AVX:
				return "avx"
			case QLexiconVal.BOTH:
				return "both"
			default:
				return String.Empty
		}
	}

	open override func ToString() -> String! {
		return "search: " + self.Domain.ToString() + ", render: " + self.Render.ToString()
	}

	public func AsYaml() -> String! {
		return self.Domain.AsYaml() + "\n" + self.Render.AsYaml()
	}

	public enum QLexiconVal { 
		case UNDEFINED = ISettings.Lexion_UNDEFINED
		case AV = ISettings.Lexion_AV
		case AVX = ISettings.Lexion_AVX
		case BOTH = ISettings.Lexion_BOTH
	}
}

open class QLexicalDomain : ISetting { 
	public static var Name: String! = "lexicon.search"

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public var Value: QLexicon.QLexiconVal!

	public static let DEFAULT: QLexicon.QLexiconVal! = QLexicon.QLexiconVal.BOTH

	public init() {
		Value = DEFAULT
	}

	public init(_ val: QLexicon.QLexiconVal!) {
		Value = val
	}

	public init(_ val: String!) {
		Value = FromString(val)
	}

	public static func FromString(_ val: String!) -> QLexicon.QLexiconVal! {
		switch val.Trim().ToUpper() {
			case "KJV":
			case "AV":
				return QLexicon.QLexiconVal.AV
			case "MODERN":
			case "MOD":
			case "AVX":
				return QLexicon.QLexiconVal.AVX
			case "BOTH":
			case "DUAL":
				return QLexicon.QLexiconVal.BOTH
			default:
				return DEFAULT
		}
	}

	public static func ToString(_ val: QLexicon.QLexiconVal!) -> String! {
		switch val {
			case QLexicon.QLexiconVal.AV:
				return "av"
			case QLexicon.QLexiconVal.AVX:
				return "avx"
			case QLexicon.QLexiconVal.BOTH:
				return "both"
			default:
				return ToString(QLexicalDomain.DEFAULT)
		}
	}

	open override func ToString() -> String! {
		return ToString(self.Value)
	}

	public func AsYaml() -> String! {
		return "lexicon.search: " + ToString()
	}
}

open class QLexicalDisplay : ISetting { 
	public static var Name: String! = "lexicon.render"

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public var Value: QLexiconVal!

	public static let DEFAULT: QLexiconVal! = QLexiconVal.AV

	public init() {
		Value = DEFAULT
	}

	public init(_ val: QLexiconVal!) {
		Value = val
	}

	public init(_ val: String!) {
		Value = FromString(val)
	}

	public static func FromString(_ val: String!) -> QLexiconVal! {
		switch val.Trim().ToUpper() {
			case "KJV":
			case "AV":
				return QLexiconVal.AV
			case "MODERN":
			case "MOD":
			case "AVX":
				return QLexiconVal.AVX
			case "BOTH":
			case "DUAL":
				return QLexiconVal.BOTH
			default:
				return DEFAULT
		}
	}

	public static func ToString(_ val: QLexiconVal!) -> String! {
		switch val {
			case QLexiconVal.AV:
				return "av"
			case QLexiconVal.AVX:
				return "avx"
			case QLexiconVal.BOTH:
				return "both"
			default:
				return ToString(QLexicalDisplay.DEFAULT)
		}
	}

	open override func ToString() -> String! {
		return ToString(self.Value)
	}

	public func AsYaml() -> String! {
		return "lexicon.render: " + ToString()
	}
}

open class QFormat : ISetting { 
	public static var Name: String! = QFormat.self.Name.Substring(1).ToLower()

	public var SettingName: String! {
		get {
			return Name
		}
	}

	public var Value: QFormatVal!

	public static let DEFAULT: QFormatVal! = QFormatVal.TEXT

	public init() {
		Value = DEFAULT
	}

	public init(_ val: QFormatVal!) {
		Value = val
	}

	public init(_ val: String!) {
		Value = FromString(val)
	}

	public static func FromString(_ val: String!) -> QFormatVal! {
		switch val.Trim().ToUpper() {
			case "JSON":
				return QFormatVal.JSON
			case "YAML":
				return QFormatVal.YAML
			case "TEXTUAL":
			case "TXT":
			case "UTF":
			case "UTF8":
			case "TEXT":
				return QFormatVal.TEXT
			case "HTML":
				return QFormatVal.HTML
			case "MARKDOWN":
			case "MD":
				return QFormatVal.MD
			default:
				return DEFAULT
		}
	}

	public static func ToString(_ val: QFormatVal!) -> String! {
		switch val {
			case QFormatVal.JSON:
				return "json"
			case QFormatVal.YAML:
				return "yaml"
			case QFormatVal.TEXT:
				return "text"
			case QFormatVal.HTML:
				return "html"
			case QFormatVal.MD:
				return "md"
			default:
				return DEFAULT.ToString()
		}
	}

	open override func ToString() -> String! {
		return ToString(self.Value)
	}

	public func AsYaml() -> String! {
		return "format: " + ToString()
	}

	public enum QFormatVal { 
		case JSON = ISettings.Formatting_JSON
		case YAML = ISettings.Formatting_YAML
		case TEXT = ISettings.Formatting_TEXT
		case HTML = ISettings.Formatting_HTML
		case MD = ISettings.Formatting_MD
	}
}

open __abstract class QVariable : QCommand { 
	public public(set) var Key: String!
	public public(set) var Value: String!

	public init(_ env: QContext!, _ text: String!, _ verb: String!, _ key: String!, _ value: String! = "") {
		super.init(QVariable: env, key + "=" + value, "assign")
		self.Key = key
		if String.IsNullOrWhiteSpace(value) {
			self.Value = GetDefault(Key)
		} else {
			self.Value = value
		}
	}

	private static func GetDefault(_ setting: String!) -> String! {
		switch setting.Trim().ToLower() {
			case "span":
				return QSpan.DEFAULT.ToString()
			case "lexicon":
				return QLexicon.DEFAULT.ToString()
			case "lexicon.search":
			case "search.lexicon":
			case "search":
				return QLexicalDomain.DEFAULT.ToString()
			case "lexicon.render":
			case "render.lexicon":
			case "render":
				return QLexicalDisplay.DEFAULT.ToString()
			case "format":
				return QFormat.DEFAULT.ToString()
			case "similarity":
				return QSimilarity.DEFAULT.ToString()
			case "similarity.lemma":
				return QSimilarityLemma.DEFAULT.ToString()
			case "similarity.word":
				return QSimilarityWord.DEFAULT.ToString()
		}
		return String.Empty
	}

	public static func CreateAssignment(_ env: QContext!, _ text: String!, _ arg: Parsed!) -> QAssign? {
		if arg.rule.EndsWith("_var") {
			if (arg.children.Length == 2) && arg.children[0].rule.EndsWith("_key", StringComparison.InvariantCultureIgnoreCase) {
				return QAssign(env, text, arg.children[0].text, arg.children[1].text)
			}
		}
		return nil
	}

	internal static func CreateAssignment(_ env: QContext!, _ text: String!, _ key: String!, _ value: String!) -> QAssign! {
		return QAssign(env, text, key, value)
	}
}

