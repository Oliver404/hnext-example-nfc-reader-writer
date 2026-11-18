import { NfcError, NfcErrorCode } from '../model/NfcError';
import { NfcRecordType } from '../model/NfcRecordType';
import { NfcWriteRequest } from '../model/NfcWriteRequest';
import { NfcRepository } from '../repository/NfcRepository';
import { CheckNfcStateUseCase } from './CheckNfcStateUseCase';

export class WriteNfcTagUseCase {
  static readonly DEFAULT_TIMEOUT_MS: number = 20000;
  private readonly repository: NfcRepository;
  private readonly checkState: CheckNfcStateUseCase;

  constructor(repository: NfcRepository, checkState: CheckNfcStateUseCase) {
    this.repository = repository;
    this.checkState = checkState;
  }

  async execute(request: NfcWriteRequest, timeoutMs: number = WriteNfcTagUseCase.DEFAULT_TIMEOUT_MS): Promise<void> {
    this.validate(request);
    this.checkState.execute();
    await this.repository.writeTag(request, timeoutMs);
  }

  private validate(request: NfcWriteRequest): void {
    const value = request.value.trim();
    const extra = request.extra.trim();
    if (value.length === 0) {
      throw new NfcError(NfcErrorCode.INVALID_INPUT, 'Enter a value to write');
    }
    switch (request.type) {
      case NfcRecordType.GEO:
        if (!/^-?\d+(\.\d+)?,\s*-?\d+(\.\d+)?$/.test(value)) {
          throw new NfcError(NfcErrorCode.INVALID_INPUT, 'Use the format lat,lon');
        }
        break;
      case NfcRecordType.MIME:
        if (extra.indexOf('/') < 1) {
          throw new NfcError(NfcErrorCode.INVALID_INPUT, 'MIME type must look like text/plain');
        }
        break;
      case NfcRecordType.EXTERNAL:
        if (extra.indexOf(':') < 1 || extra.endsWith(':')) {
          throw new NfcError(NfcErrorCode.INVALID_INPUT, 'Use domain:type, e.g. example.com:note');
        }
        break;
      case NfcRecordType.EMPTY:
      case NfcRecordType.UNKNOWN:
        throw new NfcError(NfcErrorCode.INVALID_INPUT, 'This record type cannot be written');
      default:
        break;
    }
  }
}
