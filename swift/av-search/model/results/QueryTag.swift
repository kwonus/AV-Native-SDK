open class QueryTag { 
	public private(set) var Coordinates: AVXLib.Memory.BCVW!
	public private(set) var Options: SearchMatchAny!
	public private(set) var Feature: FeatureGeneric!
	public private(set) var Fragment: SearchFragment!

	public init(_ fragment: SearchFragment!, _ options: SearchMatchAny!, _ feature: FeatureGeneric!, _ coordinates: AVXLib.Memory.BCVW!) {
		self.Fragment = fragment
		self.Options = options
		self.Feature = feature
		self.Coordinates = coordinates
	}
}

