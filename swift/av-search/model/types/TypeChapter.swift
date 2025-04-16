open __abstract class TypeChapter { 
	public public(set) var ChapterNum: UInt8 = 0
	public public(set) var TotalHits: UInt64!

	public var VerseHits: UInt64! {
		get {
			return 0
		}
	}

	public init() {

	}

	public init(_ num: UInt8) {
		self.ChapterNum = num
	}

	public func IncrementHits() {
		inc(self.TotalHits)
	}

	public __abstract func Render(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
	}
}

