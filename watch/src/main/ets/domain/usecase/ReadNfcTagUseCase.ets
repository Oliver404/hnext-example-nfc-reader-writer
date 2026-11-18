import { NfcTagInfo } from '../model/NfcTagInfo';
import { NfcRepository } from '../repository/NfcRepository';
import { CheckNfcStateUseCase } from './CheckNfcStateUseCase';

export class ReadNfcTagUseCase {
  static readonly DEFAULT_TIMEOUT_MS: number = 20000;
  private readonly repository: NfcRepository;
  private readonly checkState: CheckNfcStateUseCase;

  constructor(repository: NfcRepository, checkState: CheckNfcStateUseCase) {
    this.repository = repository;
    this.checkState = checkState;
  }

  async execute(timeoutMs: number = ReadNfcTagUseCase.DEFAULT_TIMEOUT_MS): Promise<NfcTagInfo> {
    this.checkState.execute();
    return this.repository.readTag(timeoutMs);
  }
}
