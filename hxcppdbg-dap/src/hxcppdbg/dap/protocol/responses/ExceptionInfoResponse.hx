package hxcppdbg.dap.protocol.responses;

typedef ExceptionDetails = {
    final ?message : String;

    final ?typeName : String;

    final ?fullTypeName : String;

    final ?evaluateName : String;

    final ?stackTrace : String;

    final ?innerException : Array<ExceptionDetails>;
}

typedef ExceptionInfoResponse = {
    final exceptionId : String;

    final ?description : String;

    final breakMode : String;

    final ?details : ExceptionDetails;
}