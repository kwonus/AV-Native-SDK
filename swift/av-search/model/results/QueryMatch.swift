open class QueryMatch { 
	public private(set) var Start: AVXLib.Memory.BCVW!
	public private(set) var Until: AVXLib.Memory.BCVW!
	public private(set) var Highlights: List<QueryTag!>!
	public private(set) var Expression: SearchExpression!

	public init(_ start: AVXLib.Memory.BCVW!, _ exp: inout SearchExpression!) {
		self.Expression = exp
		self.Highlights = ()
		self.Start = start
		self.Until = start
	}

	public func Add(_ match: inout QueryTag!) -> Bool {
		self.Highlights.Add(match)
		if match.Coordinates > self.Until {
			self.Until = match.Coordinates
		}
		return true
	}
}

