open class QAssign : QVariable { 
	public init(_ env: QContext!, _ text: String!, _ key: String!, _ value: String!) {
		super.init(QAssign: env, text, "assign", key, value)

	}
}

