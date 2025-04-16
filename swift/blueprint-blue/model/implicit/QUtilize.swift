import AVSearch.Interfaces
import Pinshot.PEG

public enum TagType { 
	case UNKNOWN = 0
	case History = 1
	case Macro = 2
}

open class QUtilize : QCommand, ICommand { 
	public private(set) var Tag: String!
	public private(set) var Filters: List<QFilter!>!
	public private(set) var Settings: QSettings!
	public private(set) var Expression: QFind?
	public private(set) var TagType: TagType!

	private init(_ env: QContext!, _ text: String!, _ invocation: String!, _ type: TagType!) {
		super.init(QUtilize: env, text, "use")
		self.Filters = ()
		self.Settings = QSettings(env.GlobalSettings)
		self.Tag = invocation
		self.TagType = type
		//  TO DO: (YAML?)
		// 
		//              * Filters need to be read in from the macro definition
		//              * Settings need to be read in from the macro definition
		//              * Expression needs to be read in from the macro definition
		//              
	}

	public static func Create(_ env: QContext!, _ text: String!, _ arg: Parsed!) -> QUtilize? {
		if String.IsNullOrWhiteSpace(text) {
			return nil
		}
		var numerics: Bool = arg.rule.Equals("id", StringComparison.InvariantCultureIgnoreCase)
		var labelled: Bool = arg.rule.Equals("tag", StringComparison.InvariantCultureIgnoreCase)
		if labelled {
			var invocation = QUtilize(env, text, arg.text, TagType.Macro)
			return invocation
		}
		if numerics {
			var invocation = QUtilize(env, text, arg.text, TagType.History)
			return invocation
		}
		return nil
	}
}

