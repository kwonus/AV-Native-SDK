import AVSearch.Interfaces
import AVXLib
import AVXLib.Memory

public enum WildcardType { 
	case EnglishTerm = 0
	case NuphoneTerm = 1
}

open __abstract class TypeWildcard { 
	public public(set) var Contains: List<String!>!
	public public(set) var Beginning: String?
	public public(set) var Ending: String?
	public public(set) var ContainsHyphenated: List<String!>!
	public public(set) var BeginningHyphenated: String?
	public public(set) var EndingHyphenated: String?
	public public(set) var Text: String!
	public public(set) var TermType: WildcardType!

	public init(_ text: String!, _ type: WildcardType!) {
		self.Contains = ()
		self.ContainsHyphenated = ()
		self.Text = text
		self.TermType = type
	}

	public func GetLexemes(_ settings: ISettings!) -> HashSet<UInt16!>! {
		return (self.TermType == WildcardType.EnglishTerm ? self.GetLexemesFromEnglishWildcard(settings) : self.GetLexemesFromPhoneticWildcard(settings))
	}

	public func GetLexemesFromEnglishWildcard(_ settings: ISettings!) -> HashSet<UInt16!>! {
		var lexicon = ObjectTable.AVXObjects.Mem.Lexicon.Slice(1).ToArray()
		var lexemes = HashSet<UInt16!>()
		var key: UInt16! = 0
		for lex in lexicon {
			var match: Bool = false
			inc(key)
			var kjv: String! = LEXICON.ToDisplayString(lex)
			var avx: String! = LEXICON.ToModernString(lex)
			var kjvMatch: (Bool, Bool) = [false, false]
			var avxMatch: (Bool, Bool) = [false, false]
			var hyphenated: Bool = LEXICON.IsHyphenated(lex)
			var kjvNorm: String! = (hyphenated ? LEXICON.ToSearchString(lex) : kjv)
			var avxNorm: String! = (hyphenated ? kjvNorm : avx)
			//  transliterated names (i.e. entries with hyphens) do not differ between kjv and avx
			kjvMatch.normalized = settings.SearchAsAV && ((self.Beginning == nil) || kjvNorm.StartsWith(self.Beginning, StringComparison.InvariantCultureIgnoreCase)) && ((self.Ending == nil) || kjvNorm.EndsWith(self.Ending, StringComparison.InvariantCultureIgnoreCase))
			avxMatch.normalized = settings.SearchAsAVX && ((self.Beginning == nil) || avxNorm.StartsWith(self.Beginning, StringComparison.InvariantCultureIgnoreCase)) && ((self.Ending == nil) || avxNorm.EndsWith(self.Ending, StringComparison.InvariantCultureIgnoreCase))
			match = kjvMatch.normalized || avxMatch.normalized
			if hyphenated {
				kjvMatch.hyphenated = settings.SearchAsAV && ((self.Beginning == nil) || kjv.StartsWith(self.Beginning, StringComparison.InvariantCultureIgnoreCase)) && ((self.Ending == nil) || kjv.EndsWith(self.Ending, StringComparison.InvariantCultureIgnoreCase))
				avxMatch.hyphenated = settings.SearchAsAVX && ((self.Beginning == nil) || avx.StartsWith(self.Beginning, StringComparison.InvariantCultureIgnoreCase)) && ((self.Ending == nil) || avx.EndsWith(self.Ending, StringComparison.InvariantCultureIgnoreCase))
				match = match || kjvMatch.hyphenated || avxMatch.hyphenated
			}
			if match && (self.Contains.Count > 0) {
				for piece in self.Contains {
					if kjvMatch.normalized {
						kjvMatch.normalized = kjvNorm.Contains(piece, StringComparison.InvariantCultureIgnoreCase)
					}
					if avxMatch.normalized {
						avxMatch.normalized = avxNorm.Contains(piece, StringComparison.InvariantCultureIgnoreCase)
					}
					if kjvMatch.hyphenated {
						kjvMatch.hyphenated = kjv.Contains(piece, StringComparison.InvariantCultureIgnoreCase)
					}
					if avxMatch.hyphenated {
						avxMatch.hyphenated = avx.Contains(piece, StringComparison.InvariantCultureIgnoreCase)
					}
				}
			}
			if kjvMatch.normalized || avxMatch.normalized || kjvMatch.hyphenated || avxMatch.hyphenated {
				if !lexemes.Contains(key) {
					lexemes.Add(key)
				}
			}
		}
		return lexemes
	}

	public func GetLexemesFromPhoneticWildcard(_ settings: ISettings!) -> HashSet<UInt16!>! {
		var lexicon = ObjectTable.AVXObjects.Mem.Lexicon.Slice(1).ToArray()
		var lexemes = HashSet<UInt16!>()
		return lexemes
	}
}

