import { AppContainer } from '../../di/AppContainer';
import { NfcTagInfo } from '../../domain/model/NfcTagInfo';
import { NfcError, NfcErrorCode } from '../../domain/model/NfcError';
import { OperationState } from './OperationState';

@Observed
export class ReadViewModel {
  state: OperationState = OperationState.IDLE;
  result: NfcTagInfo = new NfcTagInfo();
  error: string = '';
  private runId: number = 0;

  async start(): Promise<void> {
    const id = ++this.runId;
    this.state = OperationState.WAITING;
    this.error = '';
    try {
      const info = await AppContainer.get().readNfcTag.execute();
      if (id !== this.runId) {
        return;
      }
      this.result = info;
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
