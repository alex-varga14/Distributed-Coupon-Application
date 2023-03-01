class APIError {
  APIError();

  factory APIError.HTTPError(int code, String? message) = APIResponse;
  factory APIError.MappingError() = APIMappingError;
}

class APIResponse extends APIError {
  int code;
  String? message;

  APIResponse(this.code, this.message);
}

class APIMappingError extends APIError {
}
