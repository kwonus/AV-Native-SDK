open class PinshotSvc { 
	public private(set) var PinshotBlueURL: String!

	public init(_ pinshotURL: String!) {
		self.PinshotBlueURL = pinshotURL
	}

	public func Parse(_ command: String!) -> Task<RootParse?>! {
		var stmt = QuelleStatement(command)
		var request = HttpRequestMessage(HttpMethod.Post, self.PinshotBlueURL, Content: JsonContent.Create(stmt))
		var http: HttpClient! = HttpClient()
		var response = http.Send(request)
		var result = RootParse.Create(__await response.Content.ReadAsStreamAsync())
		return (result.ok ? result.root : nil)
	}
}

