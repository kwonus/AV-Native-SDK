open class NativeLibrary { 
	#ifdef USE_NATIVE_LIBRARIES
	private var ClientId: Guid!

	private var ClientId_1: UInt64! {
		get {
			var bytes: UInt8[] = self.ClientId.ToByteArray()
			var result: UInt64! = 0
			for i in 0 ... 8 - 1 {
				result = result << 8
				result = result || bytes[i]
			}
			return result
		}
	}

	private var ClientId_2: UInt64! {
		get {
			var bytes: UInt8[] = self.ClientId.ToByteArray()
			var result: UInt64! = 0
			for i in 8 ... 16 - 1 {
				result = result << 8
				result = result || bytes[i]
			}
			return result
		}
	}

	@DllImport("AVXSearch.dll", CharSet = CharSet.Ansi) // AVX-Search:
	private static __extern func query_create(_ client_id_1: UInt64!, _ client_id_2: UInt64!, _ blueprint: String!, _ span: UInt16!, _ lexicon: UInt8, _ similarity: UInt8, _ fuzzy_lemmata: UInt8) -> UInt64!

	@DllImport("AVXSearch.dll") // AVX-Search:
	private static __extern func query_add_scope(_ client_id_1: UInt64!, _ client_id_2: UInt64!, _ query_id: UInt64!, _ book: UInt8, _ chapter: UInt8, _ verse: UInt8) -> UInt8

	@DllImport("AVXSearch.dll", CharSet = CharSet.Ansi) // AVX-Search:
	private static __extern func query_fetch(_ client_id_1: UInt64!, _ client_id_2: UInt64!, _ query_id: UInt64!) -> String!

	@DllImport("AVXSearch.dll", CharSet = CharSet.Ansi) // AVX-Search:
	private static __extern func chapter_fetch(_ client_id_1: UInt64!, _ client_id_2: UInt64!, _ query_id: UInt64!, _ book: UInt8) -> String!

	@DllImport("AVXSearch.dll") // AVX-Search:
	private static __extern func client_release(_ client_id_1: UInt64!, _ client_id_2: UInt64!)

	@DllImport("AVXSearch.dll") // AVX-Search:
	private static __extern func query_release(_ client_id_1: UInt64!, _ client_id_2: UInt64!, _ query_id: UInt64!)

	internal init() {
		self.ClientId = Guid()
	}

	internal func query_create(_ blueprint: String!, _ span: UInt16!, _ lexicon: UInt8, _ similarity: UInt8, _ fuzzy_lemmata: UInt8) -> UInt64! {
		var result = NativeLibrary.query_create(self.ClientId_1, self.ClientId_2, blueprint, span, lexicon, similarity, fuzzy_lemmata)
		return result
	}

	internal func fetch_results(_ query_id: UInt64!, _ book: UInt8) -> String! {
		return NativeLibrary.chapter_fetch(self.ClientId_1, self.ClientId_2, query_id, book)
	}

	internal func query_add_scope(_ query_id: UInt64!, _ book: UInt8, _ chapter: UInt8, _ verse: UInt8) -> Bool {
		return (NativeLibrary.query_add_scope(self.ClientId_1, self.ClientId_2, query_id, book, chapter, verse) == (1 as? UInt8) ? true : false)
	}

	internal func fetch_summary(_ query_id: UInt64!) -> String! {
		return NativeLibrary.query_fetch(self.ClientId_1, self.ClientId_2, query_id)
	}

	internal func client_release() {
		NativeLibrary.client_release(self.ClientId_1, self.ClientId_2)
	}

	internal func query_release(_ queryId: UInt64!) {
		NativeLibrary.query_release(self.ClientId_1, self.ClientId_2, queryId)
	}

	@DllImport("AVXSearch.dll") // AVX-Search:
	internal static __extern func create_avxtext(_ path: UInt8[]) -> UInt64!

	@DllImport("AVXSearch.dll") // AVX-Search:
	internal static __extern func free_avxtext(_ data: UInt64!)
	#endif
}

open class NativeStatement { 
	#ifdef USE_NATIVE_LIBRARIES
	private var AVXTextData: UInt64!
	private var External: NativeLibrary!
	private var Address: UInt64!

	public private(set) var Summary: String!

	// This is the YAML representation of the TQuery object
	public init(_ omega: String!) {
		var omega_utf8: UInt8[] = System.Text.Encoding.UTF8.GetBytes(omega)
		self.AVXTextData = NativeLibrary.create_avxtext(omega_utf8)
		self.External = NativeLibrary()
		self.Address = 0
		//  we need to extract this from the yaml/result
		self.Summary = String.Empty
	}

	public func Search(_ blueprint: String!, _ span: UInt16!, _ lexicon: UInt8, _ similarity: UInt8, _ fuzzy_lemmata: Bool, _ scope: List<(UInt8, UInt8, UInt8)>!) -> Bool {
		self.Free()
		self.Summary = String.Empty
		self.Address = self.External.query_create(blueprint, span, lexicon, similarity, (fuzzy_lemmata ? (1 as? UInt8) : (0 as? UInt8)))
		if self.Address != 0 {
			for spec in scope {
				self.External.query_add_scope(self.Address, spec.book, spec.chapter, spec.verse)
			}
			self.Summary = self.External.fetch_summary(self.Address)
			return (self.Address != 0) && !String.IsNullOrWhiteSpace(self.Summary)
		}
		return false
	}

	public func Fetch(_ client_id: UInt64!, _ book: UInt8) -> String! {
		self.Summary = self.External.fetch_results(self.Address, book)
		return self.Summary
	}

	public func Free() {
		if self.Address != 0 {
			self.External.query_release(self.Address)
		}
		self.Address = 0
	}

	public func Release() {
		self.Free()
		NativeLibrary.free_avxtext(self.AVXTextData)
	}

	 func Finalizer() {
		self.Release()
	}
	#endif
}

open class NativeText { 
	private var address: UInt64!

	public init(_ path: UInt8[]) {
		self.address = NativeLibrary.create_avxtext(path)
	}

	public func Free() {
		if self.address != 0 {
			NativeLibrary.free_avxtext(self.address)
		}
		self.address = 0
	}

	 func Finalizer() {
		self.Free()
	}
}

