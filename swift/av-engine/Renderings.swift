open class ChapterRendering { 
	public var BookName: String!
	public var BookAbbreviation3: String!
	public var BookAbbreviation4: String!
	public var BookNumber: UInt8 = 0
	public var ChapterNumber: UInt8 = 0
	public var Verses: Dictionary<UInt8,VerseRendering!>!

	public init(_ b: UInt8, _ c: UInt8) {
		self.BookNumber = b
		self.ChapterNumber = c
		self.Verses = ()
		if (b >= 1) && (b <= 66) {
			var book: Book! = ObjectTable.AVXObjects.Mem.Book.Slice(self.BookNumber, 1).Span[0]
			self.BookName = book.name.ToString()
			self.BookAbbreviation3 = book.abbr3.ToString()
			self.BookAbbreviation4 = book.abbr4.ToString()
			if self.ChapterNumber > book.chapterCnt {
				self.ChapterNumber = 1
			}
		} else {
			self.BookNumber = 0
			self.ChapterNumber = 0
			self.BookName = String.Empty
			self.BookAbbreviation3 = String.Empty
			self.BookAbbreviation4 = String.Empty
		}
	}
}

open class VerseRendering { 
	public var Coordinates: BCVW!
	public var Words: WordRendering![]

	public init(_ b: UInt8, _ c: UInt8, _ v: UInt8, _ wc: UInt8) {
		self.Coordinates = (b, c, v, wc)
		self.Words = WordRendering[](count: wc)
	}

	public init(_ coordinates: BCVW!) {
		self.Coordinates = coordinates
		self.Words = WordRendering[](count: coordinates.WC)
	}
}

open class WordRendering { 
	public var WordKey: UInt32!
	public var Coordinates: BCVW!
	public var PnPos: PNPOS!
	public var NuPos: String!
	public var Text: String!
	public var Modern: String!
	public var Punctuation: UInt8 = 0
	public var Triggers: Dictionary<UInt32!,String!>!

	public var Modernized: Bool {
		get {
			return !self.Text.Equals(self.Modern, StringComparison.InvariantCultureIgnoreCase)
		}
	}

	// <highlight-id, feature-match-string>
	public init() {
		self.WordKey = 0
		self.Coordinates = ()
		self.Text = String.Empty
		self.Modern = String.Empty
		self.Punctuation = 0
		self.Triggers = ()
		self.PnPos = ()
		self.NuPos = String.Empty
	}
}

open class SoloVerseRendering : VerseRendering { 
	public var BookName: String!
	public var BookAbbreviation3: String!
	public var BookAbbreviation4: String!
	public var BookNumber: UInt8 = 0
	public var ChapterNumber: UInt8 = 0

	public init(_ baseclass: VerseRendering!) {
		super.init(soloVerseRendering: baseclass.Coordinates)
		self.Words = baseclass.Words
		if self.Words.Length > 0 {
			self.BookNumber = self.Words[0].Coordinates.B
			self.ChapterNumber = self.Words[0].Coordinates.C
			var book: Book! = ObjectTable.AVXObjects.Mem.Book.Slice(self.BookNumber, 1).Span[0]
			self.BookName = book.name.ToString()
			self.BookAbbreviation3 = book.abbr3.ToString()
			self.BookAbbreviation4 = book.abbr4.ToString()
		} else {
			self.BookNumber = 0
			self.ChapterNumber = 0
			self.BookName = String.Empty
			self.BookAbbreviation3 = String.Empty
			self.BookAbbreviation4 = String.Empty
		}
	}
}

