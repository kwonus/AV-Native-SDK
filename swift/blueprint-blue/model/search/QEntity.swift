open class QEntity : FeatureEntity { 
	public init(_ search: QFind!, _ text: String!, _ parse: Parsed!, _ negate: Bool) {
		super.init(QEntity: text, negate, search.Settings)
		switch parse.text {
			case "person":
				self.Entity = (Entities.men || Entities.women as? UInt16)
				return
			case "man":
				self.Entity = Entities.men
				return
			case "woman":
				self.Entity = Entities.women
				return
			case "tribe":
				self.Entity = Entities.tribes
				return
			case "city":
				self.Entity = Entities.cities
				return
			case "river":
				self.Entity = Entities.rivers
				return
			case "mountain":
				self.Entity = Entities.mountains
				return
			case "animal":
				self.Entity = Entities.animals
				return
			case "gemstone":
				self.Entity = Entities.gemstones
				return
			case "measurement":
				self.Entity = Entities.measurements
				return
			case "hitchcock_any":
			case "any_hitchcock":
			case "hitchcock":
				self.Entity = Entities.Hitchcock
				return
			case "any":
				self.Entity = 65535
				return
		}
		self.Entity = 0
	}
}

