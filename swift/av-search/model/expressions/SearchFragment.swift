import AVSearch.Model.Results

open __abstract class SearchFragment { 
	public public(set) var Hits: UInt64!
	public public(set) var Anchored: Bool = false
	public public(set) var Fragment: String!
	public public(set) var FragmentIdx: UInt16 = 0
	public public(set) var AllOf: List<SearchMatchAny!>!

	public init(_ text: String!) {
		self.Fragment = text
		self.AllOf = ()
	}

	public func Compare(_ result: QueryResult!, _ writ: inout AVXLib.Memory.Written!) -> UInt16! {
		return 0
	}
}

