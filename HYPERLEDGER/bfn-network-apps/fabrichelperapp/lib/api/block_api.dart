part of swagger.api;



class BlockApi {
  final ApiClient apiClient;

  BlockApi([ApiClient apiClient]) : apiClient = apiClient ?? defaultApiClient;

  /// Individual block information
  ///
  /// The {Block} endpoint returns information about a specific block within the Blockchain. Note that the genesis block is block zero.
  Future<Block> getBlock(int block) async {
    Object postBody = null;

    // verify required params are set
    if(block == null) {
     throw new ApiException(400, "Missing required param: block");
    }

    // create path and map variables
    String path = "/chain/blocks/{Block}".replaceAll("{format}","json").replaceAll("{" + "Block" + "}", block.toString());

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
          apiClient.deserialize(response.body, 'Block') as Block ;
    } else {
      return null;
    }
  }
}
