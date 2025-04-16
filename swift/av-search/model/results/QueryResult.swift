open class QueryResult { 
	public var BookCnt: UInt8 {
		get {
			var cnt: UInt8 = 0
			if self.Expression != nil {
				for bk in self.Expression.Books.Values {
					if bk.TotalHits > 0 {
						inc(cnt)
					}
				}
			}
			return cnt
		}
	}

	public var BookHits: UInt64! {
		get {
			var hits: UInt64! = 0
			if self.Expression != nil {
				for bk in self.Expression.Books.Values {
					if bk.TotalHits > 0 {
						inc(hits)
					}
				}
			}
			return hits
		}
	}

	public var ChapterHits: UInt64! {
		get {
			var hits: UInt64! = 0
			if self.Expression != nil {
				for bk in self.Expression.Books.Values {
					if bk.ChapterHits > 0 {
						hits = hits + bk.ChapterHits
					}
				}
			}
			return hits
		}
	}

	public public(set) var ErrorCode: UInt32!
	public public(set) var Expression: SearchExpression?
	public public(set) var QueryId: Guid!

	public var TotalHits: UInt16 {
		get {
			var hits: UInt64! = 0
			if self.Expression != nil {
				for bk in self.Expression.Books.Values {
					if bk.TotalHits > 0 {
						hits = hits + bk.TotalHits
					}
				}
			}
			return hits
		}
	}

	public var VerseHits: UInt16 {
		get {
			var hits: UInt64! = 0
			if self.Expression != nil {
				for bk in self.Expression.Books.Values {
					for ch in bk.Chapters.Values {
						if ch.VerseHits > 0 {
							hits = hits + ch.VerseHits
						}
					}
				}
			}
			return hits
		}
	}

	public init() {
		self.Expression = nil
		self.QueryId = Guid.Empty
	}

	public init(_ expression: SearchExpression!) {
		self.Expression = expression
		self.QueryId = (expression != nil ? Guid.NewGuid() : Guid.Empty)
	}
}

