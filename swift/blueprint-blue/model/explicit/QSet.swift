import AVSearch.Interfaces
import Blueprint.Model.Implicit
import Pinshot.PEG
import YamlDotNet.Core.Tokens

open class QSet : QSingleton { 
	public public(set) var Key: String!
	public public(set) var Value: String!
	public public(set) var IsValid: Bool = false

	public init(_ env: QContext!, _ text: String!, _ args: Parsed![]) {
		super.init(QSet: env, text, "set")
		if args.Length == 1 {
			var x: Int32 = 0
			var len: Int32 = args[0].children.Length
			if (len >= 2) && (len <= 4) && args[0].rule.EndsWith("_set", StringComparison.InvariantCultureIgnoreCase) {
				var cmd: Bool = args[0].children[0].rule.EndsWith("_cmd")
				if !cmd {
					x = 1
				}
				var item: String! = (cmd ? args[0].children[0].rule.Replace("_cmd", "").Replace("_", ".") : (x < len ? args[0].children[x].text.ToLower() : String.Empty))
				self.Key = item
				var value: Parsed? = ((x + 1) < len ? args[0].children[x + 1] : nil)
				self.IsValid = value != nil && !String.IsNullOrWhiteSpace(value.text) || String.IsNullOrWhiteSpace(item)
				self.Value = (value != nil && self.IsValid ? value.text.Trim() : String.Empty)
				return
			}
		}
		self.IsValid = false
		self.Key = String.Empty
		self.Value = String.Empty
	}

	open override func Execute() -> (Bool, String!) {
		var ok: Bool = self.Context.GlobalSettings.Set(self)
		return [ok, (ok ? String.Empty : "Could not save setting.")]
	}
}

