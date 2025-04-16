import System
import System.Collections.Generic
import System.Linq
import System.Runtime.Serialization
import System.Text
import System.Threading.Tasks

@DataContract
open class Parsed { 
	@DataMember
	public var rule: String!
	@DataMember
	public var text: String!
	@DataMember
	public var children: Parsed![]

	public init() {
		self.rule = String.Empty
		self.text = String.Empty
		self.children = Parsed[](count: 0)
	}
}

open class ParsedExpression { 
	public var Text: String!
	public var Ordered: Bool = false
	public var Blueprint: Parsed!
}

