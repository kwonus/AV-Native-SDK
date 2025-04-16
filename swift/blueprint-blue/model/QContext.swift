import Blueprint.Blue

public protocol IDiagnostic { 
	func AddError(_ message: String!)

	func AddWarning(_ message: String!)
}

open class QContext : IDiagnostic { 
	public var GlobalSettings: QSettings!
	public static var Home: String!
	public var InvocationCount: UInt32 = 0
	public var Fields: UInt16![]
	public private(set) var Statement: QStatement!
	public var InternalExportStream: MemoryStream!

	public static var SettingsFile: String! {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			return Path.Combine(QContext.Home, "settings.yaml").Replace("\\", "/")
		}
	}

	public static var HistoryPath: String! {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			var history: String! = Path.Combine(QContext.Home, "History").Replace("\\", "/")
			if !Directory.Exists(history) {
				Directory.CreateDirectory(history)
			}
			return history
		}
	}

	public static var MacroPath: String! {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			var labels: String! = Path.Combine(QContext.Home, "Macros").Replace("\\", "/")
			if !Directory.Exists(labels) {
				Directory.CreateDirectory(labels)
			}
			return labels
		}
	}

	public static var BackupHistoryPath: (String!, String!, String!, String!) {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			return [QContext.Home, "Backup", "-History", ".yaml"]
		}
	}

	public static var BackupMacrosPath: (String!, String!, String!, String!) {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			return [QContext.Home, "Backup", "-Macros", ".yaml"]
		}
	}

	public static var MigrationHistoryPath: (String!, String!, String!, String!) {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			return [QContext.Home, "Migration", "-History", ".yaml"]
		}
	}

	public static var MigrationMacrosPath: (String!, String!, String!, String!) {
		get {
			if !Directory.Exists(QContext.Home) {
				Directory.CreateDirectory(QContext.Home)
			}
			return [QContext.Home, "Migration", "-Macros", ".yaml"]
		}
	}

	public static let DefaultHistoryCount: UInt32! = 25

	 init() {
		QContext.Home = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AV-Bible")
		BlueprintLex.Initialize(ObjectTable.AVXObjects)
	}

	public static func GetMicrosoftStoreFolder(_ name: String!) -> String! {
		if !Directory.Exists(QContext.Home) {
			Directory.CreateDirectory(QContext.Home)
		}
		var folder: String! = Path.Combine(QContext.Home, name)
		if !Directory.Exists(folder) {
			Directory.CreateDirectory(folder)
		}
		return folder
	}

	public static func Combine(_ backup: (String!, String!, String!, String!)) -> String! {
		var combined: String! = Path.Combine(backup.folder, backup.file + backup.suffix + backup.ext)
		return combined
	}

	public init(_ statement: QStatement!) {
		Blueprint.FuzzyLex.BlueprintLex.Initialize(ObjectTable.AVXObjects)
		self.Statement = statement
		self.InvocationCount = 0
		//  This can be updated when Create() is called on Implicit clauses
		self.Fields = nil
		//  Null means that no fields were provided; In Quelle, this is different than an empty array of fields
		if String.IsNullOrEmpty(QContext.Home) {
			self.AddWarning("A session context cannot be established")
		}
		self.GlobalSettings = QSettings(Path.Combine(QContext.Home, "settings.yaml"))
		if !ObjectTable.AVXObjects.Mem.valid {
			self.AddError("Unable to load AVX Data. Without this library, other things will break")
		}
		self.InternalExportStream = ()
	}

	public func AddError(_ message: String!) {
		self.Statement.AddError(message)
	}

	public func Expand(_ label: String!) -> ExpandableInvocation? {
		if label.Length > 0 {
			if (label[0] >= "0") && (label[0] <= "9") {
				return ExpandableHistory.Deserialize(label)
			} else {
				return ExpandableMacro.Deserialize(label)
			}
		}
		return nil
	}

	public func AddWarning(_ message: String!) {
		self.Statement.AddWarning(message)
	}

	public static func DeleteHistory(_ ifFrom: UInt32! = 0, _ idUnto: UInt32! = UInt32.MaxValue, _ notBefore: UInt32? = nil, _ notAfter: UInt32? = nil) {
		//  TO DO: DELETE HISTORY (4/10/2024)
		// 
		//             UInt64 id = 1;
		//             foreach (var entry in QContext.History.Values)
		//             {
		//                 entry.Id = id++;
		//             }
		// 
		//             var notBeforeOffset = notBefore != null ? new DateTimeOffset(notBefore.Value) : DateTimeOffset.MinValue;
		//             var notAfterOffset = notAfter != null ? new DateTimeOffset(notAfter.Value) : DateTimeOffset.MaxValue;
		// 
		//             long notBeforeLong = notBeforeOffset.ToFileTime();
		//             long notAfterLong = notAfterOffset.ToFileTime();
		// 
		//             var old = QContext.History;
		//             QContext.History = new();
		//             foreach (ExpandableHistory entry in old.Values)
		//             {
		//                 if ((entry.Id >= ifFrom && entry.Id <= idUnto)
		//                 && (entry.Time >= notBeforeLong && entry.Time <= notAfterLong))
		//                 {
		//                     continue;
		//                 }
		//                 QContext.History[(int)entry.Id] = entry;
		//             }
		//             // Re-number the entries
		//             //
		//             id = 1;
		//             foreach (var entry in QContext.History.Values)
		//             {
		//                 entry.Id = id++;
		//             }
		//             ExpandableInvocation.YamlSerializer(QContext.History);
		//             
		// 
	}

	public static func GetHistory(_ rangeFrom: UInt32?, _ rangeUnto: UInt32?) -> IEnumerable<ExpandableInvocation!>! {
		var folder: String! = QContext.HistoryPath
		var from: UInt32! = (rangeFrom.HasValue ? rangeFrom.Value : 19991231)
		var unto: UInt32! = (rangeUnto.HasValue ? rangeUnto.Value : 22000101)
		var from_yr: UInt32! = from / (100 * 100)
		for year in #This language doesn't support Linq from yyyy in Directory.EnumerateDirectories(folder, '2???') order by yyyy asc select Path.GetFileName(yyyy) {
			var y: UInt32! = 0
			var yr: UInt32! = 0
			__try {
				yr = (UInt16.Parse(year) as? UInt32)
				y = (yr * 100 * 100 as? UInt32)
			}
			__catch {
				continue
			}
			if from_yr > yr {
				continue
			}
			if unto < y {
				break
			}
			var YYYY: String! = Path.Combine(folder, year)
			for month in #This language doesn't support Linq from mm in Directory.EnumerateDirectories(YYYY) order by mm asc select Path.GetFileName(mm) {
				var MM: String! = Path.Combine(YYYY, month)
				var m: UInt32! = 0
				var mo: UInt32! = 0
				var yr_mo: UInt32! = yr * 100
				__try {
					mo = (UInt8.Parse(month) as? UInt32)
					yr_mo = yr_mo + mo
					m = 100 * yr_mo
				}
				__catch {
					continue
				}
				if (from / 100) > yr_mo {
					continue
				}
				if unto < m {
					goto done
				}
				for day in #This language doesn't support Linq from dd in Directory.EnumerateDirectories(MM) order by dd asc select Path.GetFileName(dd) {
					var DD: String! = Path.Combine(MM, day)
					var d: UInt32! = 0
					__try {
						d = m + UInt8.Parse(day)
					}
					__catch {
						continue
					}
					if from > d {
						continue
					}
					if unto < d {
						goto done
					}
					for sequence in #This language doesn't support Linq from seq in Directory.EnumerateFiles(DD, '*.yaml') order by seq asc select seq.Replace('\', '/') {
						var invocation: ExpandableInvocation? = ExpandableHistory.Deserialize(yaml: sequence)
						if invocation != nil {
							__yield invocation
						}
					}
				}
			}
		}
		{
			done:

		}
	}

	public static func GetHistoryEntry(_ tag: String!) -> ExpandableInvocation? {
		return ExpandableHistory.Deserialize(tag)
	}

	public static func AppendHistory(_ history: ExpandableHistory!) {
		history.Serialize()
	}

	public static func GetMacro(_ label: String!) -> ExpandableInvocation? {
		return ExpandableMacro.Deserialize(label)
	}

	private static func GetMacroFile(_ label: String!) -> String! {
		return Path.Combine(QContext.MacroPath, label + ".yaml")
	}

	private static func IsMatch(_ macro: ExpandableMacro!, _ notBefore: UInt32!, _ notAfter: UInt32!, _ wildcard: String? = nil) -> Bool {
		var numeric: UInt32! = macro.GetDateNumeric()
		if (numeric >= notBefore) && (numeric <= notAfter) {
			if wildcard == nil {
				return true
			}
			var label: String! = macro.Tag
			var parts: String![] = ("<" + wildcard + ">").Split("*")
			var match: Bool = true
			if parts.Length >= 2 {
				for part in parts {
					if String.IsNullOrWhiteSpace(part) {
						continue
					}
					if part.StartsWith("<") {
						match = label.StartsWith(part.Substring(1), StringComparison.InvariantCultureIgnoreCase)
					}
					if part.EndsWith(">") {
						match = label.StartsWith(part.Substring(0, part.Length - 1), StringComparison.InvariantCultureIgnoreCase)
					} else {
						match = label.Contains(part, StringComparison.InvariantCultureIgnoreCase)
					}
					if !match {
						break
					}
				}
				return match
			}
		}
		return false
	}

	public static func GetMacros(_ wildcard: String!) -> IEnumerable<ExpandableInvocation!>! {
		for yaml in Directory.EnumerateFiles(QContext.MacroPath, "*.yaml") {
			var macro: ExpandableInvocation? = nil
			__try {
				var label: String! = Path.GetFileNameWithoutExtension(yaml)
				var parts: String![] = ("<" + wildcard + ">").Split("*")
				var match: Bool = true
				if parts.Length >= 2 {
					for part in parts {
						if String.IsNullOrWhiteSpace(part) {
							continue
						}
						if part.StartsWith("<") {
							match = (part.Length == 1) || label.StartsWith(part.Substring(1), StringComparison.InvariantCultureIgnoreCase)
						} else {
							if part.EndsWith(">") {
								match = (part.Length == 1) || label.StartsWith(part.Substring(0, part.Length - 1), StringComparison.InvariantCultureIgnoreCase)
							} else {
								match = label.Contains(part, StringComparison.InvariantCultureIgnoreCase)
							}
						}
						if !match {
							break
						}
					}
					if match {
						macro = ExpandableMacro.Deserialize(label)
					}
				}
			}
			__catch {

			}
			if macro != nil {
				__yield macro
			}
		}
	}

	public static func DeleteMacros(_ removals: IEnumerable<ExpandableInvocation!>!) {
		for macro in removals {
			var yaml: String! = macro.Tag + ".yaml"
			__try {
				File.Delete(Path.Combine(QContext.MacroPath, yaml))
			}
			__catch {

			}
		}
	}

	public static func GetMacros(_ notBefore: UInt32? = nil, _ notAfter: UInt32? = nil) -> IEnumerable<ExpandableInvocation!>! {
		for yaml in Directory.EnumerateFiles(QContext.MacroPath, "*.yaml") {
			var label: String! = Path.GetFileNameWithoutExtension(yaml)
			var macro: ExpandableInvocation? = nil
			__try {
				macro = ExpandableMacro.Deserialize(label)
				if macro != nil {
					if notBefore != nil || notAfter != nil {
						var time: UInt32! = macro.GetDateNumeric()
						if notBefore.HasValue && (time < notBefore.Value) {
							continue
						}
						if notAfter.HasValue && (time > notAfter.Value) {
							continue
						}
					}
				}
			}
			__catch {

			}
			if macro != nil {
				__yield macro
			}
		}
	}
}

