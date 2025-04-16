open class ExportYaml : ExportDirective { 
	open override var UsesAugmentation: Bool {
		get {
			return true
		}
	}

	internal init(_ env: QContext!, _ spec: String!, _ mode: FileCreateMode!) {
		super.init(exportYaml: env, spec, QFormatVal.YAML, mode)

	}

	open override func Update() -> DirectiveResultType! {
		var book = ObjectTable.AVXObjects.Mem.Book.Slice(0, 67).Span
		var writer: TextWriter? = nil
		__try {
			writer = (self.IsStreamingMode() ? (self.Context != nil ? StreamWriter(self.Context.InternalExportStream) : nil) : File.CreateText(self.FileSpec))
			if writer != nil {
				var serializer = SerializerBuilder()
				var builder = serializer.Build()
				for b in #This language doesn't support Linq from bk in self.Keys order by bk asc select bk {
					// string name = "# " + book[b].abbr4.ToString() + " ";
					for c in #This language doesn't support Linq from ch in self[b].Keys order by ch asc select ch {
						// string chap = name + c.ToString() + " ";
						for v in #This language doesn't support Linq from vs in self[b][c].Keys order by vs asc select vs {
							// string coord = chap + v.ToString() + ":";
							var yaml: String! = builder.Serialize(self[b][c][v])
							writer.WriteLine(yaml)
						}
					}
				}
				if writer != nil {
					writer.Flush()
					if !self.IsStreamingMode() {
						writer.Close()
					}
				}
				return DirectiveResultType.ExportSuccessful
			}
		}
		__catch {

		}
		if writer != nil {
			writer.Close()
		}
		return DirectiveResultType.ExportFailed
	}
}

