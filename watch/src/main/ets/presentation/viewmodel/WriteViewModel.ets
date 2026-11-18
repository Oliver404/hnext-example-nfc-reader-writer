import { AppContainer } from '../../di/AppContainer';
import { NfcError, NfcErrorCode } from '../../domain/model/NfcError';
import { NfcRecordType, WRITABLE_RECORD_TYPES } from '../../domain/model/NfcRecordType';
import { NfcWriteRequest } from '../../domain/model/NfcWriteRequest';
import { OperationState } from './OperationState';

@Observed
export class WriteViewModel {
  state: OperationState = OperationState.IDLE;
  typeIndex: number = 0;
  value: string = '';
  extra: string = '';
  error: string = '';
  private runId: number = 0;

  get type(): NfcRecordType {
    return WRITABLE_RECORD_TYPES[this.typeIndex];
  }

  nextType(): void {
    this.typeIndex = (this.typeIndex + 1) % WRITABLE_RECORD_TYPES.length;
    this.value = '';
    this.extra = '';
    this.state = OperationState.IDLE;
  }

  async start(): Promise<void> {
    const id = ++this.runId;
    this.state = OperationState.WAITING;
    this.error = '';
    try {
      await AppContainer.get().writeNfcTag.execute(new NfcWriteRequest(this.type, this.value, this.extra));
      if (id !== this.runId) {
        return;
      }
      this.state = OperationState.SUCCESS;
    } catch (e) {
      if (id !== this.runId) {
        return;
      }
      if (e instanceof NfcError && e.code === NfcErrorCode.CANCELLED) {
        this.state = OperationState.IDLE;
        return;
      }
      this.error = (e as Error).message;
      this.state = OperationState.ERROR;
    }
  }

  cancel(): void {
    this.runId++;
    AppContainer.get().cancelNfcOperation.execute();
    if (this.state === OperationState.WAITING) {
      this.state = OperationState.IDLE;
    }
  }
}
