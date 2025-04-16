open class ScopingFilter { 
	public var Chapters: HashSet<UInt8>!

	public private(set) var Book: UInt8 = 0

	public func GetDetails() -> Book! {
		return ObjectTable.AVXObjects.Mem.Book.Slice(self.Book, 1).Span[0]
	}

	open func GetOrderedChapters() -> IEnumerable<UInt8>! {
		for c in #This language doesn't support Linq from chapter in self.Chapters order by chapter asc select chapter {
			__yield c
		}
	}

	public func IsCompleteBook() -> Bool {
		return self.Chapters.Count == (ObjectTable.AVXObjects.Mem.Book.Slice(self.Book, 1).Span[0].chapterCnt as? Int32)
	}

	public init() {
		self.Book = 0
		self.Chapters = ()
	}

	private init(_ book: UInt8) {
		var chapterCnt: UInt8 = ObjectTable.AVXObjects.Mem.Book.Slice(book, 1).Span[0].chapterCnt
		self.Book = book
		self.Chapters = ()
		for c in 1 ... chapterCnt {
			self.Chapters.Add(c)
		}
	}

	private init(_ book: UInt8, _ chapter: UInt8) {
		var chapterCnt: UInt8 = ObjectTable.AVXObjects.Mem.Book.Slice(book, 1).Span[0].chapterCnt
		self.Book = book
		self.Chapters
	}

	private init(_ book: UInt8, _ cfrom: UInt8, _ cto: UInt8) {
		var chapterCnt: UInt8 = ObjectTable.AVXObjects.Mem.Book.Slice(book, 1).Span[0].chapterCnt
		self.Book = book
		self.Chapters = ()
		if (cfrom >= 1) && (cfrom <= chapterCnt) && (cto >= cfrom) && (cto <= chapterCnt) {
			for c in cfrom ... cto {
				self.Chapters.Add(c)
			}
		} else {
			for c in 1 ... chapterCnt {
				self.Chapters.Add(c)
			}
		}
	}

	public func InScope(_ chapter: UInt8) -> Bool {
		return self.Chapters.Contains(chapter)
	}

	public static func CreateDiscreteScope(_ textual: String!) -> ScopingFilter? {
		var book: UInt8 = GetBookNum(textual)
		return ((book >= 1) && (book <= 66) ? ScopingFilter(book) : nil)
	}

	private static func CreateBookFilters(_ textual: String!, _ ranges: ChapterRange![]) -> IEnumerable<ScopingFilter!>! {
		var book: UInt8 = GetBookNum(textual)
		if (book >= 1) && (book <= 66) {
			for range in ranges {
				__yield (range.Unto.HasValue ? ScopingFilter(book, range.From, range.Unto.Value) : ScopingFilter(book, range.From))
			}
		}
	}

	public static func GetBookNum(_ text: String!) -> UInt8 {
		//  Is it a numeric representation for the book?
		var i: Int32 = 0
		while i < text.Length {
			inc(i)
		}if i == text.Length {
			__try {
				var num: UInt8 = UInt8.Parse(text)
				if (num >= 1) && (num <= 66) {
					return num
				}
			}
			__catch {

			}
			return 0
		}
		var unspaced: String! = text.Replace(" ", "")
		var books = ObjectTable.AVXObjects.Mem.Book.Slice(0, 67).Span
		for b in 1 ... 66 {
			var name: String! = books[b].name.ToString()
			if name.Equals(text, StringComparison.InvariantCultureIgnoreCase) {
				return b
			}
			if name.Replace(" ", "").Equals(unspaced, StringComparison.InvariantCultureIgnoreCase) {
				return b
			}
		}
		for b in 1 ... 66 {
			var alt: String! = books[b].abbr2.ToString()
			if alt.Length == 0 {
				continue
			}
			if alt.StartsWith(unspaced, StringComparison.InvariantCultureIgnoreCase) {
				return b
			}
		}
		for b in 1 ... 66 {
			var alt: String! = books[b].abbr3.ToString()
			if alt.Length == 0 {
				continue
			}
			if alt.StartsWith(unspaced, StringComparison.InvariantCultureIgnoreCase) {
				return b
			}
		}
		for b in 1 ... 66 {
			var alt: String! = books[b].abbr4.ToString()
			if alt.Equals(unspaced, StringComparison.InvariantCultureIgnoreCase) {
				return b
			}
		}
		for b in 1 ... 66 {
			var alt: String! = books[b].abbrAlternates.ToString()
			//  at this point, we only handle the first alternate if it exists
			if alt.Length == 0 {
				continue
			}
			if alt.Equals(unspaced, StringComparison.InvariantCultureIgnoreCase) {
				return b
			}
		}
		return 0
	}

	public func Ammend(_ ammendment: ScopingFilter!) -> Bool {
		if self.Book != ammendment.Book {
			return false
		}
		if !self.IsCompleteBook() {
			for c in ammendment.Chapters {
				if !self.Chapters.Contains(c) {
					self.Chapters.Add(c)
				}
			}
		}
		return true
	}

	public static func Create(_ textual: String!, _ ranges: ChapterRange![]) -> IEnumerable<ScopingFilter!>? {
		var book: UInt8 = GetBookNum(textual)
		if (book >= 1) && (book <= 66) {
			if ranges.Length == 0 {
				var discreteFilter: ScopingFilter? = CreateDiscreteScope(textual)
				if discreteFilter != nil {
					__yield discreteFilter
				}
			} else {
				var filters: IEnumerable<ScopingFilter!>! = CreateBookFilters(textual, ranges)
				for filter in filters {
					__yield filter
				}
			}
		} else {
			switch textual.Trim().ToLower().Replace(" ", "") {
				case "oldtestament":
				case "o.t.":
				case "ot":
					for i in 1 ... 39 {
						__yield ScopingFilter(i)
					}
				case "newtestament":
				case "n.t.":
				case "nt":
					for i in 40 ... 66 {
						__yield ScopingFilter(i)
					}
				case "law":
				case "pentateuch":
					for i in 1 ... 5 {
						__yield ScopingFilter(i)
					}
				case "history":
					for i in 6 ... 17 {
						__yield ScopingFilter(i)
					}
				case "wisdomandpoetry":
				case "wisdom&poetry":
				case "wisdom+poetry":
				case "wisdom":
				case "poetry":
					for i in 18 ... 22 {
						__yield ScopingFilter(i)
					}
				case "majorprophets":
					for i in 23 ... 27 {
						__yield ScopingFilter(i)
					}
				case "minorprophets":
					for i in 28 ... 39 {
						__yield ScopingFilter(i)
					}
				case "prophets":
					for i in 23 ... 39 {
						__yield ScopingFilter(i)
					}
				case "gospels":
					for i in 40 ... 43 {
						__yield ScopingFilter(i)
					}
				case "gospelsandacts":
				case "gospels&acts":
				case "gospels+acts":
					for i in 40 ... 44 {
						__yield ScopingFilter(i)
					}
				case "churchepistle":
				case "churchepistles":
					for i in 45 ... 51 {
						__yield ScopingFilter(i)
					}
				case "pastoralepistle":
				case "pastoralepistles":
					for i in 52 ... 57 {
						__yield ScopingFilter(i)
					}
				case "generalepistle":
				case "generalepistles":
				case "jewishepistle":
				case "jewishepistles":
					for i in 58 ... 65 {
						__yield ScopingFilter(i)
					}
				case "epistle":
				case "epistles":
					for i in 45 ... 65 {
						__yield ScopingFilter(i)
					}
				case "generalepistlesandrevelation":
				case "generalepistles&revelation":
				case "generalepistles+revelation":
				case "generalepistleandrevelation":
				case "generalepistle&revelation":
				case "generalepistle+revelation":
					for i in 58 ... 66 {
						__yield ScopingFilter(i)
					}
			}
		}
	}
}

