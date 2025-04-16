open __abstract class TypeBook { 
	public public(set) var BookNum: UInt8 = 0
	public public(set) var ChapterCnt: UInt8 = 0
	public public(set) var ChapterHits: UInt64!
	public public(set) var TotalHits: UInt64!
	public public(set) var VerseHits: UInt64!
	public public(set) var Matches: Dictionary<UInt32!,QueryMatch!>!

	public init() {
		self.Matches = ()
	}
}

