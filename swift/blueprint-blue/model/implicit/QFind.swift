open class ExpressionBlueprint : ParsedExpression { 
	public init() {
		self.Text = String.Empty
		self.Ordered = false
		self.Blueprint = nil
	}

	public init(_ blueprint: Parsed!, _ text: String? = nil, _ ordered: Bool? = nil) {
		self.Text = (text != nil ? text : String.Empty)
		self.Ordered = (ordered.HasValue ? ordered.Value : false)
		self.Blueprint = blueprint
		if text == nil {
			var child: Parsed! = blueprint.children[0]
			var quoted: Bool = child.rule.Equals("ordered") && (child.children.Length > 0)
			var unquoted: Bool = child.rule.Equals("unordered") && (child.children.Length > 0)
			if quoted || unquoted {
				self.Text = child.text
			}
		}
		if ordered == nil {
			var child: Parsed! = blueprint.children[0]
			var quoted: Bool = child.rule.Equals("ordered") && (child.children.Length > 0)
			var unquoted: Bool = child.rule.Equals("unordered") && (child.children.Length > 0)
			if quoted || unquoted {
				self.Ordered = quoted
			}
		}
	}
}

open class QFind : SearchExpression, IDiagnostic { 
	private var Diagnostics: IDiagnostic!

	public func AddFilters(_ filters: IEnumerable<QFilter!>!) {
		for filter in filters {
			var results = ScopingFilter.Create(filter.Textual, filter.Ranges)
			if results != nil {
				for result in results {
					if !self.Scope.ContainsKey(result.Book) {
						self.Scope[result.Book] = result
					} else {
						self.Scope[result.Book].Ammend(result)
					}
				}
			}
		}
	}

	private init(_ diagnostics: IDiagnostic!, _ selection: QSelectionCriteria!, _ text: String!, _ expression: ParsedExpression?, _ useExplicitSettings: Bool) {
		super.init(QFind: selection.Settings, selection.Results)
		self.IsValid = false
		self.Diagnostics = diagnostics
		self.Scope = ()
		self.Expression = nil
		self.Settings = selection.Settings
		self.AddFilters(selection.Scope)
		var blueprint: Parsed? = (expression != nil ? expression.Blueprint : nil)
		self.Fragments = ()
		var validExpression: Bool = blueprint != nil && (blueprint.rule == "search") && (blueprint.children.Length == 1) && !String.IsNullOrWhiteSpace(text)
		if blueprint != nil && validExpression {
			var child: Parsed! = blueprint.children[0]
			var ordered: Bool = child.rule.Equals("ordered") && (child.children.Length > 0)
			var unordered: Bool = child.rule.Equals("unordered") && (child.children.Length > 0)
			if ordered || unordered {
				self.Expression = expression
				self.Quoted = ordered
				var fulltext: String! = text.Trim()
				for gchild in child.children {
					var anchored: Bool = gchild.rule.Equals("fragment") && (gchild.children.Length > 0)
					var unanchored: Bool = gchild.rule.Equals("unanchored") && (gchild.children.Length == 1) && gchild.children[0].rule.Equals("fragment") && (gchild.children[0].children.Length > 0)
					validExpression = anchored || unanchored
					if validExpression {
						var frag: Parsed! = (anchored ? gchild : gchild.children[0])
						var fragment: QFragment! = QFragment(self, frag, anchored)
						self.Fragments.Add(fragment)
					} else {
						break
					}
				}
			}
			if validExpression {
				self.IsValid = true
				return
			}
		}
		validExpression = blueprint != nil && blueprint.rule.StartsWith("hashtag_") && (blueprint.children.Length == 1) && !String.IsNullOrWhiteSpace(text)
		if validExpression && blueprint != nil {
			var invocation = QUtilize.Create(selection.Context, blueprint.text, blueprint.children[0])
			if invocation != nil {
				selection.SearchExpression = invocation.Expression
				if selection.Scope.Count == 0 {
					selection.Scope = invocation.Filters
				}
				if !useExplicitSettings {
					selection.Settings.CopyFrom(invocation.Settings)
				}
				self.IsValid = true
				return
			}
			validExpression = false
		}
		if useExplicitSettings {
			self.IsValid = true
		}
		self.Expression = nil
		//  fall through here, makes *expression* invalid (even though selection might be valid)
		self.IsValid = self.IsValid || (self.Scope.Count > 0)
	}

	public static func Create(_ diagnostics: IDiagnostic!, _ selection: QSelectionCriteria!, _ text: String!, _ expression: ParsedExpression?, _ useExplicitSettings: Bool) -> QFind? {
		//  TODO: Consider that this could be a full or demoted/partial macro and process accordingly
		// 
		var search: QFind? = QFind(diagnostics, selection, text, expression, useExplicitSettings)
		return (search.IsValid ? search : nil)
	}

	public func AsYaml() -> List<String!>! {
		return ICommand.YamlSerializer(self)
	}

	public func AddError(_ message: String!) {
		self.Diagnostics.AddError(message)
	}

	public func AddWarning(_ message: String!) {
		self.Diagnostics.AddWarning(message)
	}
}

