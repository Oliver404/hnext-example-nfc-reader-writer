import { NfcRepository } from '../repository/NfcRepository';

export class CancelNfcOperationUseCase {
  private readonly repository: NfcRepository;

  constructor(repository: NfcRepository) {
    this.repository = repository;
  }

  execute(): void {
    this.repository.cancel();
  }
}
