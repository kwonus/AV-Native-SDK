open class QID { 
	public static var Months: String![]

	public var year: UInt16!
	public var month: UInt8 = 0
	public var day: UInt8 = 0
	public var sequence: UInt32!

	public static static func Greater(_ x: QID!, _ y: QID!) -> Bool {
		return (x.year > y.year) || ((x.year == y.year) && (x.month > y.month)) || ((x.year == y.year) && (x.month == y.month) && (x.day > y.day)) || ((x.year == y.year) && (x.month == y.month) && (x.day == y.day) && (x.sequence > y.sequence))
	}

	public static static func Less(_ x: QID!, _ y: QID!) -> Bool {
		return y > x
	}

	public init(_ y: UInt16!, _ m: UInt8, _ d: UInt8, _ seq: UInt32!) {
		self.year = y
		self.month = m
		self.day = d
		self.sequence = seq
	}

	public init(_ seq: UInt32?) {
		var today: DateTime! = DateTime.Now
		self.year = (today.Year as? UInt16)
		self.month = (today.Month as? UInt8)
		self.day = (today.Day as? UInt8)
		self.sequence = (seq.HasValue ? seq.Value : 0)
		if seq == nil {
			var folder: String! = self.AsYamlFolder()
			var previous: UInt32! = 0
			if Directory.Exists(folder) {
				for file in #This language doesn't support Linq from item in Directory.EnumerateFiles(folder, '*.yaml') order by item.Length desc, item desc select Path.GetFileNameWithoutExtension(item) {
					__try {
						previous = UInt32.Parse(file)
						break
					}
					__catch {
						continue
						//  user might have save files in here, keep trying.
					}
				}
			} else {
				Directory.CreateDirectory(folder)
			}
			self.sequence = previous + 1
		}
	}

	public init() {
		self.year = 0
		self.month = 0
		self.day = 0
		self.sequence = 0
	}

	// TodayOnly looks like this: ("", parts[0])
	//  Otherwise looks like this: (parts[0], parts[1])
	private convenience init(_ parts: String![]) {
		self.init(QID: (parts.Length == 2 ? parts[0] : String.Empty), (parts.Length == 2 ? parts[1] : (parts.Length == 1 ? parts[0] : "0")))

	}

	private convenience init(_ seq: String!, _ todayOnly: Bool) {
		self.init(QID: String.Empty, (todayOnly ? seq : "0"))

	}

	public init(_ date: String!, _ seq: String!) {
		var valid: Bool = false
		switch date.Length {
			case 8:
				valid = ParseLonghand(date)
			case 3:
				valid = ParseShorthand(date)
			case 1:
			case 2:
				valid = ParseThisMonthOnly(date)
			case 0:
				valid = PseudoParseTodayOnly()
		}
		if valid {
			valid = seq.Length > 0
		}
		if valid {
			__try {
				self.sequence = UInt32.Parse(seq)
			}
			__catch {
				sequence = 0
			}
		}
		if !valid {
			sequence = (year = (month = (day = 0)))
		}
	}

	public convenience init(_ id: String!) {
		self.init(QID: id.Split("."))

	}

	public func AsTodayOnly() -> String? {
		var today: DateTime! = DateTime.Now
		if (self.year == today.Year) && (self.month == today.Month) && (self.day == today.Day) {
			var sequence: String! = QID.Base36((self.sequence as? Int32))
			if sequence.Length > 0 {
				if (sequence[0] >= "0") && (sequence[0] <= "9") {
					return sequence
				}
				return "0" + sequence
			}
		}
		return nil
	}

	public func AsCurrentMonthOnly() -> String? {
		var today: DateTime! = DateTime.Now
		if (self.year == today.Year) && (self.month == today.Month) {
			var id: StringBuilder! = StringBuilder(6)
			var day: String! = self.day.ToString()
			id.Append(day)
			id.Append(".")
			var sequence: String! = self.sequence.ToString()
			id.Append(self.sequence)
			return id.ToString()
		}
		//  if today is 4/1/2024, then I can execute macros last month (e.g. 3/2/2024 as #2._, or 3/31/2024 as #31._
		if (self.year == today.Year) && (self.month == (today.Month - 1)) && (today.Day < self.day) {
			var id: StringBuilder! = StringBuilder(6)
			var day: String! = self.day.ToString()
			id.Append(day)
			id.Append(".")
			var sequence: String! = self.sequence.ToString()
			id.Append(self.sequence)
			return id.ToString()
		}
		//  special case for january:
		//  if today is 1/1/2024, then I can execute macros last month (e.g. 12/2/2023 as #2._, or 12/31/2023 as #31._
		if (self.year == (today.Year - 1)) && (self.month == 12) && (today.Month == 1) && (today.Day < self.day) {
			var id: StringBuilder! = StringBuilder(6)
			var day: String! = self.day.ToString()
			id.Append(day)
			id.Append(".")
			var sequence: String! = self.sequence.ToString()
			id.Append(self.sequence)
			return id.ToString()
		}
		return nil
	}

	public func AsShorthand() -> String! {
		if (self.year >= 2000) && (self.month >= 1) && (self.month <= 12) && (self.day >= 1) && (self.day <= 31) {
			var id: StringBuilder! = StringBuilder(6)
			var yy: Int32 = self.year - 2020
			id.Append(QID.Base36(yy))
			if self.month < 10 {
				id.Append(self.month.ToString())
			} else {
				switch self.month {
					case 10:
						id.Append("A")
					case 11:
						id.Append("B")
					case 12:
						id.Append("C")
				}
			}
			if self.day < 10 {
				id.Append(self.day.ToString())
			} else {
				id.Append(((("A" as? Int32) + self.day) - 10 as? Char))
			}
			id.Append(".")
			id.Append(QID.Base36((self.sequence as? Int32)))
			return id.ToString()
		}
		return "000.0"
	}

	public func AsLonghand() -> String! {
		if (self.year >= 2000) && (self.month >= 1) && (self.month <= 12) && (self.day >= 1) && (self.day <= 31) {
			return self.AsDate() + "." + QID.Base36((self.sequence as? Int32))
		}
		return "00000000.0"
	}

	public func AsYamlPath() -> String! {
		var folder: String! = self.AsYamlFolder()
		return Path.Combine(folder, self.sequence.ToString() + ".yaml").Replace("\\", "/")
	}

	public func AsYamlFolder() -> String! {
		return Path.Combine(QContext.HistoryPath, self.year.ToString(), self.month.ToString(), self.day.ToString()).Replace("\\", "/")
	}

	open override func ToString() -> String! {
		var today: DateTime! = DateTime.Now
		if (today.Year - 10) < self.year {
			return self.AsShorthand()
		} else {
			if (today.Year - 10) > self.year {
				return self.AsLonghand()
			}
		}
		//  otherwise, we are on the 10-year mark
		if today.Month < self.month {
			return self.AsShorthand()
		} else {
			if today.Month > self.month {
				return self.AsLonghand()
			}
		}
		//  otherwise, we are on the very month of the 10-year mark
		if today.Day < self.day {
			return self.AsShorthand()
		}
		return self.AsLonghand()
	}

	public static func Today() -> String! {
		var today: DateTime! = DateTime.Now
		var date: StringBuilder! = StringBuilder(11)
		date.Append(today.Day.ToString("D2"))
		date.Append(" ")
		date.Append(QID.Months[today.Month])
		date.Append(" ")
		date.Append(today.Year.ToString("D4"))
		return date.ToString()
	}

	// We never really [fully] care is a bad date passes thru (i.e. 2/31/202021) ...
	//  reason: we will not deserialize invocation, because that date will not be in our history
	//  therefore: anomoly will be detected downstream (this applies to all date processing in this class)
	public func AsDate() -> String! {
		if (self.year >= 2000) && (self.month >= 1) && (self.month <= 12) && (self.day >= 1) && (self.day <= 31) {
			var date: StringBuilder! = StringBuilder(11)
			date.Append(self.day.ToString("D2"))
			date.Append(" ")
			date.Append(QID.Months[self.month])
			date.Append(" ")
			date.Append(self.year.ToString("D4"))
			return date.ToString()
		}
		return "99 XYZ 9999"
	}

	private func PseudoParseTodayOnly() -> Bool {
		var today: DateTime! = DateTime.Now
		self.year = (today.Year as? UInt16)
		self.month = (today.Month as? UInt8)
		self.day = (today.Day as? UInt8)
		return true
	}

	// We can parse [approximately] the last thirty days, by just supplying the day (year and month parts are not required)
	//  If the day passed is later than today's day of the month, then the previous month is implied.
	private func ParseThisMonthOnly(_ tag: String!) -> Bool {
		var today: DateTime! = DateTime.Now
		self.year = (today.Year as? UInt16)
		self.month = (today.Month as? UInt8)
		__try {
			self.day = UInt8.Parse(tag)
			if (self.day >= 1) && (self.day <= 31) {
				if self.day > today.Day {
					dec(self.month)
					if self.month == 0 {
						self.month = 12
						dec(self.year)
					}
				}
				return true
			}
		}
		__catch {

		}
		return false
	}

	private func ParseShorthand(_ date: String!) -> Bool {
		__try {
			if date.Length == 3 {
				var today: DateTime! = DateTime.Now
				self.year = ((today.Year / 10) * 10 as? UInt16)
				self.year = self.year + (date[0] - "0" as? UInt8)
				//  Base 16
				if (date[1] >= "1") && (date[1] <= "9") {
					self.month = (date[1] - "0" as? UInt8)
				} else {
					if (date[1] >= "a") && (date[1] <= "c") {
						self.month = ((10 + date[1]) - "a" as? UInt8)
					} else {
						if (date[1] >= "A") && (date[1] <= "C") {
							self.month = ((10 + date[1]) - "A" as? UInt8)
						} else {
							return false
						}
					}
				}
				//  Base 36
				self.day = QID.UnBase36(date[2])
				if (self.day > 31) || (self.day < 1) {
					return false
				}
			}
			return (self.year >= 2000) && (self.month >= 1) && (self.month <= 12) && (self.day >= 1) && (self.day <= 31)
		}
		__catch {
			return false
		}
	}

	private func ParseLonghand(_ date: String!) -> Bool {
		return false
	}

	public static func UnBase36(_ digit: Char) -> UInt8 {
		if (digit >= "0") && (digit <= "9") {
			return (digit - "0" as? UInt8)
		}
		if (digit >= "A") && (digit <= "Z") {
			return (10 + (digit - "A") as? UInt8)
		}
		if (digit >= "a") && (digit <= "z") {
			return (10 + (digit - "a") as? UInt8)
		}
		return UInt8.MaxValue
	}

	public static func UnBase36(_ digits: String!) -> Int32 {
		var positive: Bool = true
		var i: Int32 = 0
		var accumulator: Int32 = 0
		for digit in digits {
			if (inc(i) == 0) && (digit == "-") {
				positive = false
			} else {
				var value: UInt8 = UnBase36(digit)
				if value != UInt8.MaxValue {
					accumulator = accumulator * 36
					accumulator = accumulator + value
				}
			}
		}
		return (positive ? accumulator : -accumulator)
	}

	public static func Base36(_ digit: UInt8, _ defaultVal: Char) -> Char {
		if digit < 10 {
			return ("0" + digit as? Char)
		}
		if digit < 36 {
			return ("A" + (digit - 10) as? Char)
		}
		return defaultVal
	}

	public static func Base36(_ value: Int32) -> String! {
		var minus: Bool = value < 0
		if minus {
			value = value * -1
		}
		var digits: StringBuilder! = StringBuilder(3)
		var remainder: Int32 = value
		while true {
			var modula: UInt8 = (remainder % 36 as? UInt8)
			var digit: Char = Base36(modula, "!")
			digits.Insert(0, digit)
			if value < 36 {
				break
			}
			value = value / 36
		}if minus {
			digits.Insert(0, "-")
		}
		return digits.ToString()
	}
}

