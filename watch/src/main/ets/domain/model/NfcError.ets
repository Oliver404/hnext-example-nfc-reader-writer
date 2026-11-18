export enum NfcErrorCode {
  NOT_SUPPORTED,
  DISABLED,
  PERMISSION_DENIED,
  TIMEOUT,
  CANCELLED,
  UNSUPPORTED_TAG,
  READ_ONLY,
  INVALID_INPUT,
  IO_FAILED
}

export class NfcError extends Error {
  code: NfcErrorCode;

  constructor(code: NfcErrorCode, message: string) {
    super(message);
    this.code = code;
  }
}
