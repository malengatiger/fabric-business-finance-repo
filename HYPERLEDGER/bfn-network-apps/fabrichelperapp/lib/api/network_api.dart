part of swagger.api;



class NetworkApi {
  final ApiClient apiClient;

  NetworkApi([ApiClient apiClient]) : apiClient = apiClient ?? defaultApiClient;

  /// List of network peers
  ///
  /// The /network/peers endpoint returns a list of all existing network connections for the target peer node. The list includes both validating and non-validating peers.
  Future<PeersMessage> getPeers() async {
    Object postBody = null;

    // verify required params are set

    // create path and map variables
    String path = "/network/peers".replaceAll("{format}","json");

    // query params
    List<QueryParam> queryParams = [];
    Map<String, String> headerParams = {};
    Map<String, String> formParams = {};
    
    List<String> contentTypes = [];

    String contentType = contentTypes.length > 0 ? contentTypes[0] : "application/json";
    List<String> authNames = [];

    if(contentType.startsWith("multipart/form-data")) {
      bool hasFields = false;
      MultipartRequest mp = new MultipartRequest(null, null);
      
      if(hasFields)
        postBody = mp;
    }
    else {
          }

    var response = await apiClient.invokeAPI(path,
                                             'GET',
                                             queryParams,
                                             postBody,
                                             headerParams,
                                             formParams,
                                             contentType,
                                             authNames);

    if(response.statusCode >= 400) {
      throw new ApiException(response.statusCode, response.body);
    } else if(response.body != null) {
      return 
          apiClient.deserialize(response.body, 'PeersMessage') as PeersMessage ;
    } else {
      return null;
    }
  }
}
