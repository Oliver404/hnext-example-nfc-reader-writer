import { NfcError, NfcErrorCode } from '../model/NfcError';
import { NfcRepository } from '../repository/NfcRepository';

/** Throws NfcError unless NFC hardware exists and is switched on. */
export class CheckNfcStateUseCase {
  private readonly repository: NfcRepository;

  constructor(repository: NfcRepository) {
    this.repository = repository;
  }

  execute(): void {
    if (!this.repository.isNfcAvailable()) {
      throw new NfcError(NfcErrorCode.NOT_SUPPORTED, 'NFC is not supported on this device');
    }
    if (!this.repository.isNfcEnabled()) {
      throw new NfcError(NfcErrorCode.DISABLED, 'NFC is off. Turn it on in Settings');
    }
  }
}
