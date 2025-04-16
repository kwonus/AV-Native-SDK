open __abstract class SearchExpression { 
	public public(set) var Quoted: Bool = false
	public public(set) var Expression: ParsedExpression?
	public public(set) var Fragments: List<SearchFragment!>!
	public public(set) var Settings: ISettings!
	public public(set) var Scope: SearchScope!

	public var EmptySelection: Bool {
		get {
			return (self.Expression == nil) && (self.Scope.Count == 0)
		}
	}

	public public(set) var IsValid: Bool = false
	public public(set) var Books: Dictionary<UInt8,QueryBook!>!
	public public(set) var Query: QueryResult!
	public private(set) var Hits: UInt64!

	public init(_ settings: ISettings!, _ query: QueryResult!) {
		self.Quoted = false
		self.Expression = nil
		self.Fragments = ()
		self.Books = ()
		self.Scope = ()
		self.Settings = settings
		self.Query = query
		self.IsValid = false
	}

	public func AddScope(_ scope: SearchScope!) {
		self.Scope = scope
	}

	public func IncrementHits() {
		inc(self.Hits)
	}
}

