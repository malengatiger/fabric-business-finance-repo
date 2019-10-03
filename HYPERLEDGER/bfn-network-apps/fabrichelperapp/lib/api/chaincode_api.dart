part of swagger.api;



class ChaincodeApi {
  final ApiClient apiClient;

  ChaincodeApi([ApiClient apiClient]) : apiClient = apiClient ?? defaultApiClient;

  /// Service endpoint for Chaincode operations
  ///
  /// The /chaincode endpoint receives requests to deploy, invoke, and query a target Chaincode. This service endpoint implements the JSON RPC 2.0 specification with the payload identifying the desired Chaincode operation within the &#39;method&#39; field.
  Future<ChaincodeOpSuccess> chaincodeOp(ChaincodeOpPayload chaincodeOpPayload) async {
    Object postBody = chaincodeOpPayload;

    // verify required params are set
    if(chaincodeOpPayload == null) {
     throw new ApiException(400, "Missing required param: chaincodeOpPayload");
    }

    // create path and map variables
    String path = "/chaincode".replaceAll("{format}","json");

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
                                             'POST',
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
          apiClient.deserialize(response.body, 'ChaincodeOpSuccess') as ChaincodeOpSuccess ;
    } else {
      return null;
    }
  }
}
