open class QueryChapter : TypeChapter { 
	public private(set) var ChapterNum: UInt8 = 0

	public init(_ num: UInt8, _ zeroHits: Bool = false) {
		super.init(queryChapter: num)
		self.TotalHits = ((zeroHits ? 0 : 1) as? UInt64)
	}

	public func AddScope(_ range: ScopingFilter!) -> Bool {
		return false
	}

	open override func Render(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
		if settings.RenderingFormat == ISettings.Formatting_JSON {
			return self.RenderJSON(settings, scope)
		} else {
			if settings.RenderingFormat == ISettings.Formatting_YAML {
				return self.RenderYAML(settings, scope)
			} else {
				if settings.RenderingFormat == ISettings.Formatting_TEXT {
					return self.RenderTEXT(settings, scope)
				} else {
					if settings.RenderingFormat == ISettings.Formatting_HTML {
						return self.RenderHTML(settings, scope)
					} else {
						if settings.RenderingFormat == ISettings.Formatting_MD {
							return self.RenderMD(settings, scope)
						}
					}
				}
			}
		}
		return String.Empty
	}

	private func RenderJSON(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
		var modernize: Bool = settings.RenderAsAVX
		return String.Empty
	}

	private func RenderYAML(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
		var modernize: Bool = settings.RenderAsAVX
		return String.Empty
	}

	private func RenderTEXT(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
		var modernize: Bool = settings.RenderAsAVX
		return String.Empty
	}

	private func RenderHTML(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
		var modernize: Bool = settings.RenderAsAVX
		return String.Empty
	}

	private func RenderMD(_ settings: ISettings!, _ scope: IEnumerable<ScopingFilter!>?) -> String! {
		var modernize: Bool = settings.RenderAsAVX
		return String.Empty
	}
}

