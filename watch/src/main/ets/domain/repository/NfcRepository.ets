import { NfcTagInfo } from '../model/NfcTagInfo';
import { NfcWriteRequest } from '../model/NfcWriteRequest';

export interface NfcRepository {
  isNfcAvailable(): boolean;

  isNfcEnabled(): boolean;

  /** Waits for a tag to be presented and reads it. Rejects with NfcError. */
  readTag(timeoutMs: number): Promise<NfcTagInfo>;

  /** Waits for a tag to be presented and writes the request to it. Rejects with NfcError. */
  writeTag(request: NfcWriteRequest, timeoutMs: number): Promise<void>;

  /** Aborts a pending read/write; the pending promise rejects with CANCELLED. */
  cancel(): void;
}
