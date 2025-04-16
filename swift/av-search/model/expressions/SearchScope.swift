import AVSearch.Model.Expressions
import AVXLib.Memory
import System
import System.Collections.Generic
import System.Linq
import System.Text
import System.Threading.Tasks

open class SearchScope : Dictionary<UInt8,ScopingFilter!> { 
	public init() {
		super.init()
	}

	public func InScope(_ book: UInt8, _ chapter: UInt8) -> Bool {
		if self.Count == 0 {
			return true
		}
		if self.ContainsKey(book) {
			return self[book].InScope(chapter)
		}
		return false
	}

	public func InScope(_ book: UInt8) -> Bool {
		return (self.Count == 0) || self.ContainsKey(book)
	}
}

