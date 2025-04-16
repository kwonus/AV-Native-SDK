open class QSelectionCriteria : QCommand, ICommand { 
	public var SearchExpression: QFind?
	public var UtilizeExpression: ExpandableInvocation?
	public var Scope: List<QFilter!>!
	public var UtilizeScope: ExpandableInvocation?
	public var Assignments: List<QAssign!>!
	public var UtilizeAssignments: ExpandableInvocation?
	public var Settings: QSettings!
	public var Results: QueryResult!

	private init(_ env: QContext!, _ results: QueryResult!, _ text: String!, _ verb: String!) {
		super.init(QSelectionCriteria: env, text, verb)
		self.SearchExpression = nil
		self.Assignments = ()
		self.Scope = ()
		self.Settings = QSettings(env.GlobalSettings)
		self.Results = results
		self.UtilizeExpression = nil
		self.UtilizeScope = nil
		self.UtilizeAssignments = nil
	}

	public static func CreateSelectionCriteria(_ env: QContext!, _ results: QueryResult!, _ criteria: Parsed!) -> QSelectionCriteria! {
		var selection = QSelectionCriteria(env, results, criteria.text, criteria.rule)
		var user_supplied_settings: Bool = false
		var user_supplied_scoping: Bool = false
		if criteria.rule.Equals("selection_statement", StringComparison.InvariantCultureIgnoreCase) && (criteria.children.Length >= 1) {
			var expression: ParsedExpression? = nil
			var pexpression: Parsed? = nil
			for block in criteria.children {
				if block.children.Length > 1 {
					switch block.rule.ToLower() {
						case "settings_block":
							for setting in block.children {
								selection.SettingsFactory(setting, possibleMacro: false)
							}
							user_supplied_settings = true
						case "scoping_block":
							for filter in block.children {
								selection.FilterFactory(filter, possibleMacro: false)
							}
					}
				} else {
					if block.children.Length == 1 {
						switch block.rule.ToLower() {
							case "expression_block":
								pexpression = block.children[0]
								if selection.ExpressionMacroDetection(env, pexpression) {
									expression = (selection.UtilizeExpression != nil ? selection.UtilizeExpression.Expression : nil)
								} else {
									expression = ExpressionBlueprint(blueprint: pexpression)
								}
							case "settings_block":
								selection.SettingsFactory(block.children[0], possibleMacro: true)
								user_supplied_settings = true
							case "scoping_block":
								selection.FilterFactory(block.children[0], possibleMacro: true)
						}
					}
				}
			}
			if user_supplied_settings {
				for assignment in selection.Assignments {
					selection.Settings.Assign(assignment)
				}
			}
			//  SearchExpression(QFind) subsumes expression, settings, and filters in selection object
			//  (they need not be processed in this method when expression is part of imperative)
			//  Processing of partial macros is late in the ExecutionProcess
			//  From here on out, all macros are treated as "partial"
			//  (this little block below, propogates expression macros into its siblings, if appropriate)
			if selection.UtilizeExpression != nil {
				if !user_supplied_scoping {
					selection.UtilizeScope = selection.UtilizeExpression
				}
				if !user_supplied_settings {
					selection.UtilizeAssignments = selection.UtilizeExpression
				}
			}
			selection.SearchExpression = QFind.Create(env, selection, selection.Text, expression, user_supplied_settings)
		}
		return selection
	}

	private func ExpressionMacroDetection(_ env: QContext!, _ exp: Parsed!) -> Bool {
		if exp.rule.StartsWith("hashtag_") && (exp.children.Length == 1) {
			//  this is a partial utilization [macro or history]
			var invocation = QUtilize.Create(self.Context, exp.text, exp.children[0])
			if invocation != nil {
				self.UtilizeExpression = ExpandableInvocation.Deserialize(invocation)
				if self.UtilizeExpression == nil {
					env.AddError("Unable to locate supplied tag for " + (invocation.TagType == TagType.Macro ? "macro" : (invocation.TagType == TagType.History ? "history item" : "unknown tag type")))
				}
			} else {
				env.AddError("Unable to determine utilization tag type")
			}
			return true
		}
		return false
	}

	private func FilterFactory(_ filter: Parsed!, _ possibleMacro: Bool) {
		var instance: QFilter? = QFilter.Create(filter, self.Context)
		if instance != nil {
			self.Scope.Add(instance)
		} else {
			if possibleMacro {
				if filter.rule.StartsWith("hashtag_") && (filter.children.Length == 1) {
					//  this is a partial utilization [macro or history]
					var invocation = QUtilize.Create(self.Context, filter.text, filter.children[0])
					if invocation != nil {
						self.UtilizeScope = ExpandableInvocation.Deserialize(invocation)
						self.Scope.Clear()
						for item in invocation.Filters {
							self.Scope.Add(item)
						}
					}
				}
			}
		}
	}

	private func SettingsFactory(_ variable: Parsed!, _ possibleMacro: Bool) {
		if variable.children.Length == 1 {
			var assignment: QAssign? = QVariable.CreateAssignment(self.Context, variable.text, variable.children[0])
			if assignment != nil {
				self.Assignments.Add(assignment)
			} else {
				if possibleMacro {
					if variable.rule.StartsWith("hashtag_") && (variable.children.Length == 1) {
						//  this is a partial utilization [macro or history]
						var invocation = QUtilize.Create(self.Context, variable.text, variable.children[0])
						if invocation != nil {
							self.UtilizeAssignments = ExpandableInvocation.Deserialize(invocation)
							self.Settings.CopyFrom(invocation.Settings)
						}
					}
				}
			}
		}
	}

	internal func ConditionallyUpdateSpanToFragmentCount() {
		if self.SearchExpression != nil && (self.SearchExpression.Settings.SearchSpan != 0) {
			var fragCnt: UInt16! = (self.SearchExpression.Fragments.Count as? UInt16)
			if fragCnt > self.SearchExpression.Settings.SearchSpan {
				self.Settings.Span.Update(fragCnt)
			}
		}
	}
}

