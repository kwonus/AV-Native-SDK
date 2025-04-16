open class ExportJson : ExportDirective { 
	open override var UsesAugmentation: Bool {
		get {
			return true
		}
	}

	public init() {
		super.init()

	}

	internal init(_ env: QContext!, _ spec: String!, _ mode: FileCreateMode!) {
		super.init(exportJson: env, spec, QFormatVal.JSON, mode)

	}

	// JSON is no longer suppored
	open override func Update() -> DirectiveResultType! {
		return DirectiveResultType.ExportFailed
	}
}

