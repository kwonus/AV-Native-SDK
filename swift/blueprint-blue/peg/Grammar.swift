@DataContract
open class RootParse { 
	@DataMember
	public var input: String!
	@DataMember
	public var result: Parsed![]
	@DataMember
	public var error: String!

	public static func Create(_ stream: Stream!) -> (RootParse!, Bool) {
		__try {
			var serializer = DataContractJsonSerializer(RootParse.self)
			var root = serializer.ReadObject(stream)
			if root != nil {
				return [(root as? RootParse), true]
			}
		}
		__catch {

		}
		return [RootParse() /* Property Initializers : error = "Exception thrown during deserialization", input = "", result = Parsed[](count: 0) */, false]
	}
}

@DataContract
open class RawParseResult { 
	@DataMember
	public var input: String!
	@DataMember
	public var result: String!
	@DataMember
	public var error: String!

	public init() {
	}

	public static func Create(_ stream: Stream!) -> (RawParseResult!, Bool) {
		__try {
			var serializer = DataContractJsonSerializer(RawParseResult.self)
			var root = serializer.ReadObject(stream)
			if root != nil {
				return [(root as? RawParseResult), true]
			}
		}
		__catch {

		}
		return [RawParseResult() /* Property Initializers : error = "Exception thrown during deserialization", input = "", result = "" */, false]
	}
}

open class QuelleStatement { 
	public private(set) var command: String!

	public init(_ stmt: String!) {
		self.command = stmt
	}
}

