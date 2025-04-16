import System
import System.Collections.Generic
import System.Linq
import System.Reflection.Metadata.Ecma335
import System.Text
import System.Threading.Tasks

open class NUPhoneGen { 
	private var _Embeddings: UInt8[]
	private static var graphemeFirst: Dictionary<UInt8,Dictionary<String!,List<NUPhoneRecord!>!>!>![] = ([Features.Instance.nuphone_grapheme_lookup, Features.Instance.nuphone_lexicon_lookup] as? Dictionary<UInt8,Dictionary<String!,List<NUPhoneRecord!>!>!>![])
	private static var lexiconFirst: Dictionary<UInt8,Dictionary<String!,List<NUPhoneRecord!>!>!>![] = ([Features.Instance.nuphone_lexicon_lookup, Features.Instance.nuphone_grapheme_lookup] as? Dictionary<UInt8,Dictionary<String!,List<NUPhoneRecord!>!>!>![])

	public private(set) var Word: String!
	public private(set) var Phonetic: String!

	public var Embeddings: UInt8[] {
		get {
			var zero: UInt8[] = UInt8[](count: 0)
			if self.Phonetic.Length == 0 {
				return zero
			}
			if _Embeddings == nil {
				var len = Features.NUPhoneLen(self.Phonetic)
				var i: UInt8
				var features: UInt8[] = UInt8[](count: len)
				while i < len {
					i = 0
					features[i] = 0
					features[i] = 0
					inc(i)
				}i = 0
				var ored: Bool = false
				for c in self.Phonetic {
					if i >= len {
						return zero
					}
					switch c {
						case "{":
							ored = true
							continue
						case "}":
							ored = false
							inc(i)
							continue
						case "|":
							continue
					}
					if Features.nuphone_inventory.ContainsKey(c) {
						features[i] = features[i] || Features.nuphone_inventory[c]
					}
					if !ored {
						inc(i)
					}
				}
				self._Embeddings = features
			}
			return self._Embeddings
		}
	}

	public init(_ word: String!, _ raw: Bool = false) {
		if !raw {
			self.Word = word.Trim().ToLower()
			self.Phonetic = self.Generate(word)
		} else {
			self.Word = String.Empty
			self.Phonetic = word.Trim()
		}
	}

	private static func SubBytes(_ input: UInt8[], _ startIdx: Int32, _ untilIdx: Int32) -> UInt8[] {
		if untilIdx > startIdx {
			var result = UInt8[](count: untilIdx - startIdx)
			for i in startIdx ... untilIdx - 1 {
				var idx: Int32 = i - startIdx
				result[idx] = (i < input.Length ? input[i] : (0 as? UInt8))
			}
		}
		return UInt8[](count: 0)
	}

	public func Compare(_ candidate: NUPhoneGen!, _ threshold: UInt8) -> UInt16? {
		var `self` = self.Embeddings
		var other = candidate.Embeddings
		if (`self`.Length == 0) || (other.Length == 0) {
			return 0
		}
		if threshold > 100 {
			return nil
		}
		var maxLen: Int32 = (`self`.Length > other.Length ? `self`.Length : other.Length)
		var minLen: Int32 = (`self`.Length < other.Length ? `self`.Length : other.Length)
		var diff: Int32 = maxLen - minLen
		var percent: Int32 = ((maxLen - diff) * 100) / maxLen
		return (percent >= threshold ? Compare(candidate) : (nil as? UInt16))
		//  null represents that comparison does not meet threshold for further comparison 
	}

	public func Compare(_ candidate: NUPhoneGen!) -> UInt16! {
		var `self` = self.Embeddings
		var other = candidate.Embeddings
		if (`self`.Length == 0) || (other.Length == 0) {
			return 0
		}
		var maxLen: Int32 = (`self`.Length > other.Length ? `self`.Length : other.Length)
		var minLen: Int32 = (`self`.Length < other.Length ? `self`.Length : other.Length)
		if maxLen == 1 {
			return Compare(`self`[0], other[0])
		}
		var score: UInt64!
		var mean: UInt64!
		if minLen <= 3 {
			var first = Compare(`self`[0], other[0])
			var bag = NUPhoneGen.BagCompare(`self`, other)
			score = bag.score + first
			mean = score / (bag.cnt + 1 as? UInt64)
			return (mean as? UInt16)
		}
		if (minLen >= 4) && (minLen <= 6) {
			var begin1 = NUPhoneGen.Compare(`self`[0], other[0])
			var begin2 = NUPhoneGen.Compare(`self`[1], other[1])
			var last2 = NUPhoneGen.Compare(`self`[`self`.Length - 2], other[other.Length - 2])
			var last1 = NUPhoneGen.Compare(`self`[`self`.Length - 1], other[other.Length - 1])
			var selfBag = NUPhoneGen.SubBytes(`self`, 1, `self`.Length - 1)
			var otherBag = NUPhoneGen.SubBytes(other, 1, other.Length - 1)
			var bag = NUPhoneGen.BagCompare(`self`, other)
			score = bag.score + begin1 + begin2 + last2 + last1
			mean = score / (bag.cnt + 4 as? UInt64)
			return (mean as? UInt16)
		}
		var begin = ([NUPhoneGen.Compare(`self`[0], other[0]), NUPhoneGen.Compare(`self`[1], other[1]), NUPhoneGen.Compare(`self`[2], other[2])] as? UInt64![])
		var end = ([NUPhoneGen.Compare(`self`[`self`.Length - 3], other[other.Length - 3]), NUPhoneGen.Compare(`self`[`self`.Length - 2], other[other.Length - 2]), NUPhoneGen.Compare(`self`[`self`.Length - 1], other[other.Length - 1])] as? UInt64![])
		var selfRemainer = NUPhoneGen.SubBytes(`self`, 2, `self`.Length - 2)
		var otherRemainder = NUPhoneGen.SubBytes(other, 2, other.Length - 2)
		var remainder = NUPhoneGen.BagCompare(`self`, other)
		score = remainder.score
		for i in 0 ... 3 - 1 {
			score = score + begin[i]
			score = score + end[i]
		}
		mean = score / (remainder.cnt + 6 as? UInt64)
		return (mean as? UInt16)
	}

	public static func BagCompare(_ a: UInt8[], _ b: UInt8[]) -> (UInt64!, UInt8) {
		var maxLen = (a.Length > b.Length ? a.Length : b.Length)
		var minLen = (a.Length < b.Length ? a.Length : b.Length)
		if maxLen > UInt8.MaxValue {
			return [0, UInt8.MaxValue]
		}
		if (a.Length == 0) || (b.Length == 0) {
			return [0, (maxLen as? UInt8)]
		}
		var scores = Dictionary<UInt8,Dictionary<UInt8,UInt16!>!>()
		for i in 0 ... a.Length - 1 {
			if scores.ContainsKey(a[i]) {
				continue
			}
			var candidates = Dictionary<UInt8,UInt16!>()
			for j in 0 ... b.Length - 1 {
				if candidates.ContainsKey(b[j]) {
					continue
				}
				var score = NUPhoneGen.Compare(a[i], b[j])
				candidates[b[j]] = score
			}
			scores[a[i]] = candidates
		}
		var total: UInt64! = 0
		for key in scores.Keys {
			var checks = scores[key]
			var maxScore: UInt64! = 0
			for test in checks.Values {
				if test > maxScore {
					maxScore = test
				}
			}
			total = total + maxScore
		}
		return [total, (maxLen as? UInt8)]
	}

	private static func Compare(_ a: UInt8, _ b: UInt8) -> UInt16! {
		var va = Features.IsVowel(a)
		var vb = Features.IsVowel(b)
		if va != vb {
			return 0
		}
		if va {
			return CompareVowel(a, b)
		} else {
			return CompareConsonant(a, b)
		}
	}

	private static func CompareVowel(_ a: UInt8, _ b: UInt8) -> UInt16! {
		var xa = Features.GetXaxis(a)
		var xb = Features.GetXaxis(b)
		var xdiff = (xa > xb ? xa - xb : xb - xa)
		//  absolute value
		var ya = Features.GetYaxis(a)
		var yb = Features.GetYaxis(b)
		var ydiff = (ya > yb ? ya - yb : yb - ya)
		//  absolute value
		var diff = xdiff + ydiff
		switch diff {
			case 0:
				return 10000
			case 1:
				return 9900
			case 2:
				return 9700
			case 3:
				return 9300
			default:
				return 8500
		}
	}

	private static func CompareConsonant(_ a: UInt8, _ b: UInt8) -> UInt16! {
		var xa = Features.GetXaxis(a)
		var xb = Features.GetXaxis(b)
		var xdiff = (xa > xb ? xa - xb : xb - xa)
		//  absolute value
		var ya = Features.GetYaxis(a)
		var yb = Features.GetYaxis(b)
		var ydiff = (ya > yb ? ya - yb : yb - ya)
		//  absolute value
		var diff = xdiff + ydiff
		var penalty: UInt16! = (Features.IsVoicedConsonant(a) != Features.IsVoicedConsonant(b) ? (1000 as? UInt16) : (0 as? UInt16))
		switch diff {
			case 0:
				return (10000 - penalty as? UInt16)
			case 1:
				return (9800 - penalty as? UInt16)
			case 2:
				return (9400 - penalty as? UInt16)
			case 3:
				return (8600 - penalty as? UInt16)
			case 4:
				return (7000 - penalty as? UInt16)
			default:
				return (3800 - penalty as? UInt16)
		}
	}

	private static func GetShortestVariant(_ variants: List<NUPhoneRecord!>!) -> String! {
		var variant: String? = nil
		for candidate in variants {
			var normalized = Features.Instance.NormalizeIntoNUPhone(candidate.nuphone)
			if (variant == nil) || (variant.Length > normalized.Length) {
				variant = normalized
			}
		}
		return (variant != nil ? variant : String.Empty)
	}

	private func Generate(_ segment: String!) -> String! {
		var table: Dictionary<String!,List<NUPhoneRecord!>!>!
		var len = (segment.Length as? UInt8)
		for lookup in graphemeFirst {
			if lookup.ContainsKey(len) {
				table = lookup[len]
				if table.ContainsKey(segment) {
					var records: List<NUPhoneRecord!>! = table[segment]
					return GetShortestVariant(records)
				}
			}
		}
		var builder = StringBuilder(segment.Length + 3)
		var lookups = (len > 2 ? lexiconFirst : graphemeFirst)
		for lookup in lookups {
			for i in 1 ... len - 1 {
				var sublen: UInt8 = (len - i as? UInt8)
				if lookup.ContainsKey(sublen) {
					table = lookup[sublen]
					var `left` = segment.Substring(0, sublen)
					var `right` = segment.Substring(sublen)
					if table.ContainsKey(`left`) {
						var records: List<NUPhoneRecord!>! = table[`left`]
						var shortest = GetShortestVariant(records)
						return shortest + self.Generate(`right`)
					} else {
						if table.ContainsKey(`right`) {
							var records: List<NUPhoneRecord!>! = table[`right`]
							var shortest = GetShortestVariant(records)
							return self.Generate(`left`) + shortest
						}
					}
				}
			}
		}
		return Features.Instance.NormalizeIntoNUPhone(segment)
	}

	enum Position { 
		case Left
		case Right
	}
}

