import AVSearch.Model.Expressions
import AVSearch.Model.Results
import AVSearch.Model.Types

open class AVQueryManager { 
	public var ClientQueries: Dictionary<Guid!,Dictionary<Guid!,QueryResult!>!>!

	public init() {
		self.ClientQueries = ()
	}

	public func Create(_ client_id: inout Guid!, _ expressions: inout List<SearchExpression!>!) -> QueryResult? {
		// var query = new TQuery(expressions);
		//  query;
		return nil
	}

	public func ReleaseAll(_ client_id: inout Guid!) -> Bool {
		var client = ClientQueries[client_id]
		if client != nil {
			client.Clear()
			ClientQueries.Remove(client_id)
			return true
		}
		return false
	}

	public func ReleaseQuery(_ client_id: inout Guid!, _ query_id: inout Guid!) -> Bool {
		var client = ClientQueries[client_id]
		if client != nil && client.ContainsKey(query_id) {
			client.Remove(query_id)
			return true
		}
		return false
	}
}

