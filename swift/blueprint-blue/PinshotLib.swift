open static class Pinshot_RustFFI { 
	private var ExpectedVersion: UInt16! = 20775
	private var _VERSION: String! = "UNKNOWN"

	public var LibraryVersion: (UInt32!, Bool) {
		get {
			var actual: UInt16! = get_library_revision()
			var version: UInt16! = assert_grammar_revision(Pinshot_RustFFI.ExpectedVersion)
			Console.WriteLine("Using Quelle Grammar version: " + Pinshot_RustFFI.VERSION)
			if actual != Pinshot_RustFFI.ExpectedVersion {
				Console.WriteLine("Using Quelle Grammar version: " + Pinshot_RustFFI.VERSION_EXPECTED)
			}
			return [actual, (version != 0) && (actual == Pinshot_RustFFI.ExpectedVersion)]
		}
	}

	public var VERSION: String! {
		get {
			if Pinshot_RustFFI._VERSION == "UNKNOWN" {
				var actual: UInt16! = get_library_revision()
				Pinshot_RustFFI._VERSION = ((actual && 61440) >> 12).ToString() + "." + ((actual && 3840) >> 8).ToString() + "." + (actual && 255).ToString("X")
				if actual != Pinshot_RustFFI.ExpectedVersion {
					Pinshot_RustFFI._VERSION = "actual: " + Pinshot_RustFFI._VERSION + " // " + "expected: " + Pinshot_RustFFI.VERSION_EXPECTED
				}
			}
			return Pinshot_RustFFI._VERSION
		}
	}

	public var VERSION_EXPECTED: String! {
		get {
			return ((ExpectedVersion && 61440) >> 12).ToString() + "." + ((ExpectedVersion && 3840) >> 8).ToString() + "." + (ExpectedVersion && 255).ToString("X")
		}
	}

	@DllImport("pinshot_blue.dll", EntryPoint = "assert_grammar_revision")
	internal __extern func assert_grammar_revision(_ revision: UInt16!) -> UInt16!

	@DllImport("pinshot_blue.dll", EntryPoint = "get_library_revision")
	public __extern func get_library_revision() -> UInt16!

	@DllImport("pinshot_blue.dll", EntryPoint = "create_quelle_parse_raw")
	internal __extern func pinshot_blue_raw_parse(_ stmt: String!) -> ParsedStatementHandle!

	@DllImport("pinshot_blue.dll", EntryPoint = "create_quelle_parse")
	internal __extern func pinshot_blue_parse(_ stmt: String!) -> ParsedStatementHandle!

	@DllImport("pinshot_blue.dll", EntryPoint = "delete_quelle_parse")
	internal __extern func pinshot_blue_free(_ memory: IntPtr!)
}

internal class ParsedStatementHandle : SafeHandle { 
	open override var IsInvalid: Bool {
		get {
			return self.handle == IntPtr.Zero
		}
	}

	public init() {
		super.init(parsedStatementHandle: IntPtr.Zero, true)
	}

	public func AsString() -> String! {
		var len: Int32 = 0
		while Marshal.ReadByte(handle, len) != 0 {
			inc(len)
		}var buffer: UInt8[] = UInt8[](count: len)
		Marshal.Copy(handle, buffer, 0, buffer.Length)
		return Encoding.UTF8.GetString(buffer)
	}

	open override func ReleaseHandle() -> Bool {
		if !self.IsInvalid {
			Pinshot_RustFFI.pinshot_blue_free(handle)
		}
		return true
	}
}

open class PinshotLib { 
	public init() {

	}

	private func TrimParse(_ parse: Parsed!) {
		parse.text = parse.text.Trim()
		TrimParses(parse.children)
	}

	private func TrimParses(_ parses: Parsed![]) {
		for parse in parses {
			TrimParse(parse)
		}
	}

	public func Parse(_ stmt: String!) -> (String!, RootParse?) {
		__using let handle = Pinshot_RustFFI.pinshot_blue_parse(stmt) {
		var result = handle.AsString()
		__using let ms = MemoryStream(Encoding.UTF8.GetBytes(result)) {
		//  Deserialization from JSON
		var deserializer: DataContractJsonSerializer! = DataContractJsonSerializer(RootParse.self)
		var root = (deserializer.ReadObject(ms) as? RootParse)
		if String.IsNullOrEmpty(root.error) {
			TrimParses(root.result)
		}
		return [result, root]
		}
		}
	}

	public func RawParse(_ stmt: String!) -> (String!, RawParseResult?) {
		__using let handle = Pinshot_RustFFI.pinshot_blue_raw_parse(stmt) {
		var result = handle.AsString()
		__using let ms = MemoryStream(Encoding.Unicode.GetBytes(result)) {
		//  Deserialization from JSON
		var deserializer: DataContractJsonSerializer! = DataContractJsonSerializer(RawParseResult.self)
		var root = (deserializer.ReadObject(ms) as? RawParseResult)
		return [result, root]
		}
		}
	}
}

