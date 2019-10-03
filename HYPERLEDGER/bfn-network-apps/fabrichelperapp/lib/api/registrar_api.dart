part of swagger.api;



class RegistrarApi {
  final ApiClient apiClient;

  RegistrarApi([ApiClient apiClient]) : apiClient = apiClient ?? defaultApiClient;

  /// Delete user login tokens from local storage
  ///
  /// The /registrar/{enrollmentID} endpoint deletes any existing client login tokens from local storage. After the completion of this request, the target user will no longer be able to execute transactions.
  Future<OK> deleteUserRegistration(String enrollmentID) async {
    Object postBody = null;

    // verify required params are set
    if(enrollmentID == null) {
     throw new ApiException(400, "Missing required param: enrollmentID");
    }

    // create path and map variables
    String path = "/registrar/{enrollmentID}".replaceAll("{format}","json").replaceAll("{" + "enrollmentID" + "}", enrollmentID.toString());

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
                                             'DELETE',
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
          apiClient.deserialize(response.body, 'OK') as OK ;
    } else {
      return null;
    }
  }
  /// Retrieve user enrollment certificate
  ///
  /// The /registrar/{enrollmentID}/ecert endpoint retrieves the enrollment certificate for a given user that has registered with the certificate authority. If the user has registered, a confirmation message will be returned containing the URL-encoded enrollment certificate. Otherwise, an error will result.
  Future<OK> getUserEnrollmentCertificate(String enrollmentID) async {
    Object postBody = null;

    // verify required params are set
    if(enrollmentID == null) {
     throw new ApiException(400, "Missing required param: enrollmentID");
    }

    // create path and map variables
    String path = "/registrar/{enrollmentID}/ecert".replaceAll("{format}","json").replaceAll("{" + "enrollmentID" + "}", enrollmentID.toString());

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
          apiClient.deserialize(response.body, 'OK') as OK ;
    } else {
      return null;
    }
  }
  /// Confirm the user has registered with the certificate authority
  ///
  /// The /registrar/{enrollmentID} endpoint confirms whether the specified user has registered with the certificate authority. If the user has registered, a confirmation message will be returned. Otherwise, an authorization failure will result.
  Future<OK> getUserRegistration(String enrollmentID) async {
    Object postBody = null;

    // verify required params are set
    if(enrollmentID == null) {
     throw new ApiException(400, "Missing required param: enrollmentID");
    }

    // create path and map variables
    String path = "/registrar/{enrollmentID}".replaceAll("{format}","json").replaceAll("{" + "enrollmentID" + "}", enrollmentID.toString());

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
          apiClient.deserialize(response.body, 'OK') as OK ;
    } else {
      return null;
    }
  }
  /// Retrieve user transaction certificates
  ///
  /// The /registrar/{enrollmentID}/tcert endpoint retrieves the transaction certificates for a given user that has registered with the certificate authority. If the user has registered, a confirmation message will be returned containing an array of URL-encoded transaction certificates. Otherwise, an error will result. The desired number of transaction certificates is specified with the optional &#39;count&#39; query parameter. The default number of returned transaction certificates is 1 and 500 is the maximum number of certificates that can be retrieved with a single request.
  Future<OK> getUserTransactionCertificate(String enrollmentID, { String count }) async {
    Object postBody = null;

    // verify required params are set
    if(enrollmentID == null) {
     throw new ApiException(400, "Missing required param: enrollmentID");
    }

    // create path and map variables
    String path = "/registrar/{enrollmentID}/tcert".replaceAll("{format}","json").replaceAll("{" + "enrollmentID" + "}", enrollmentID.toString());

    // query params
    List<QueryParam> queryParams = [];
    Map<String, String> headerParams = {};
    Map<String, String> formParams = {};
    if(count != null) {
      queryParams.addAll(_convertParametersForCollectionFormat("", "count", count));
    }
    
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
          apiClient.deserialize(response.body, 'OK') as OK ;
    } else {
      return null;
    }
  }
  /// Register a user with the certificate authority
  ///
  /// The /registrar endpoint receives requests to register a user with the certificate authority. The request must supply the registration id and password within the payload. If the registration is successful, the required transaction certificates are received and stored locally. Otherwise, an error is displayed alongside with a reason for the failure.
  Future<OK> registerUser(Secret secret) async {
    Object postBody = secret;

    // verify required params are set
    if(secret == null) {
     throw new ApiException(400, "Missing required param: secret");
    }

    // create path and map variables
    String path = "/registrar".replaceAll("{format}","json");

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
          apiClient.deserialize(response.body, 'OK') as OK ;
    } else {
      return null;
    }
  }
}
