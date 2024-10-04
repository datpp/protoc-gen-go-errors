# `protoc-gen-go-errors`

## 1. Functionality
Extend `errors.proto` to define error messages using proto files. It is fully compatible with `kratos` errors.

## 2. Installation
```bash
go install github.com/datpp/protoc-gen-go-errors
```

## 3. Usage Instructions

### 3.1 Include the `errors.proto` file in the project:
```proto
syntax = "proto3";

package errors;

option go_package = "github.com/go-kratos/kratos/v2/errors;errors";
option java_multiple_files = true;
option java_package = "com.github.kratos.errors";
option objc_class_prefix = "KratosErrors";

import "google/protobuf/descriptor.proto";

extend google.protobuf.EnumOptions {
  int32 default_code = 1108;
  string default_message = 2108;
}

extend google.protobuf.EnumValueOptions {
  int32 code = 1109;
  string message = 2109;
}
```

### 3.2 Define error codes
```proto
syntax = "proto3";

package example;

import "errors/errors.proto";

option go_package = "github.com/datpp/protoc-gen-go-errors/examples";

enum ErrorReason {
  // Set default error code
  option (errors.default_code) = 500;
  // Set default error message
  option (errors.default_message) = "Unknown error";

  // Parameter error
  ERROR_REASON_INVALID_PARAM = 0 [(errors.code) = 400, (errors.message) = "Invalid parameter"];
  // User unauthorized
  ERROR_REASON_USER_UNAUTHORIZED = 1 [(errors.code) = 401, (errors.message) = "User unauthorized"];
  // User forbidden
  ERROR_REASON_USER_FORBIDDEN = 2 [(errors.code) = 403, (errors.message) = "User forbidden"];
  // 409 Business error: %d status conflict
  ERROR_REASON_STATUS_CONFLICT = 3 [(errors.code) = 409, (errors.message) = "%d status conflict"];
}
```

### 3.3 Generate the stub code
Generate code using the following:
```bash
make errors

protoc --proto_path=. \
       --go_out=paths=source_relative:. \
       --go-errors_out=paths=source_relative:. \
       $(EXAMPLE_PROTO_FILES)
```

The generated code:
```go
package examples

import (
	fmt "fmt"
	errors "github.com/go-kratos/kratos/v2/errors"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the kratos package it is being compiled against.
const _ = errors.SupportPackageIsVersion1

// Invalid parameter
func IsErrorReasonInvalidParam(err error) bool {
	if err == nil {
		return false
	}
	e := errors.FromError(err)
	return e.Reason == ErrorReason_REASON_INVALID_PARAM.String() && e.Code == 400
}

// Invalid parameter
func ErrorReasonInvalidParamWithCustomMessage(format string, args ...interface{}) *errors.Error {
	return errors.New(400, ErrorReason_REASON_INVALID_PARAM.String(), fmt.Sprintf(format, args...))
}

// Invalid parameter

func ErrorReasonInvalidParam() *errors.Error {
	return errors.New(400, ErrorReason_REASON_INVALID_PARAM.String(), "Invalid parameter")
}

// User unauthorized
func IsErrorReasonUserUnauthorized(err error) bool {
	if err == nil {
		return false
	}
	e := errors.FromError(err)
	return e.Reason == ErrorReason_REASON_USER_UNAUTHORIZED.String() && e.Code == 401
}

// User unauthorized
func ErrorReasonUserUnauthorizedWithCustomMessage(format string, args ...interface{}) *errors.Error {
	return errors.New(401, ErrorReason_REASON_USER_UNAUTHORIZED.String(), fmt.Sprintf(format, args...))
}

// User unauthorized

func ErrorReasonUserUnauthorized() *errors.Error {
	return errors.New(401, ErrorReason_REASON_USER_UNAUTHORIZED.String(), "User unauthorized")
}

// User forbidden
func IsErrorReasonUserForbidden(err error) bool {
	if err == nil {
		return false
	}
	e := errors.FromError(err)
	return e.Reason == ErrorReason_REASON_USER_FORBIDDEN.String() && e.Code == 403
}

// User forbidden
func ErrorReasonUserForbiddenWithCustomMessage(format string, args ...interface{}) *errors.Error {
	return errors.New(403, ErrorReason_REASON_USER_FORBIDDEN.String(), fmt.Sprintf(format, args...))
}

// User forbidden

func ErrorReasonUserForbidden() *errors.Error {
	return errors.New(403, ErrorReason_REASON_USER_FORBIDDEN.String(), "User forbidden")
}

// 409 Business error: xxx status conflict
func IsErrorReasonStatusConflict(err error) bool {
	if err == nil {
		return false
	}
	e := errors.FromError(err)
	return e.Reason == ErrorReason_REASON_STATUS_CONFLICT.String() && e.Code == 409
}

// 409 Business error: xxx status conflict
func ErrorReasonStatusConflictWithCustomMessage(format string, args ...interface{}) *errors.Error {
	return errors.New(409, ErrorReason_REASON_STATUS_CONFLICT.String(), fmt.Sprintf(format, args...))
}

// 409 Business error: xxx status conflict

func ErrorReasonStatusConflict(args ...interface{}) *errors.Error {
	return errors.New(409, ErrorReason_REASON_STATUS_CONFLICT.String(), fmt.Sprintf("%d status conflict", args...))
}
```

### 3.4 Use error codes in business logic
```go
// The first method: using proto to define error messages without argument
func A() error {
    return ErrorReasonInvalidParam()
}

// second method: using proto to define error messages with argument
func B() error {
    // REASON_STATUS_CONFLICT = 3 [(errors.code) = 409, (errors.message) = "%d status conflict"];
    // `100` will be pass to %d
    return ErrorReasonStatusConflict(100)
}

// third method: Overwrite proto error information (previous usage)
func C() error {
    return ErrorReasonStatusConflictWithCustomMessage("User is existed")
	// or
	return ErrorReasonStatusConflictWithCustomMessage(" The user %d is existed", 100)
}

// fourth method: using errors to carry information, root causes, and metadata
func C() error {
    return ErrorReasonStatusConflict(100).
        WithCause(fmt.Errorf("status has already been updated")).
        WithMetadata(map[string]string{"uid": "xxxxxxxxx"})
}
```
