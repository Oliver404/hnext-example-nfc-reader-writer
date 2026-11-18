import { tag } from '@kit.ConnectivityKit';
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NfcError, NfcErrorCode } from '../../domain/model/NfcError';
import { NfcErrorMapper } from './NfcErrorMapper';

const DISCOVERY_TECHS: number[] = [
  tag.NFC_A, tag.NFC_B, tag.ISO_DEP, tag.NFC_F, tag.NFC_V,
  tag.NDEF, tag.NDEF_FORMATABLE, tag.MIFARE_CLASSIC, tag.MIFARE_ULTRALIGHT
];

/**
 * Foreground "reader mode" discovery. Reader mode stays enabled for the whole
 * operation (discovery + read/write) so the tag remains connectable.
 */
export class NfcDiscoveryDataSource {
  private readonly element: bundleManager.ElementName;
  private abort: ((error: NfcError) => void) | undefined = undefined;

  constructor(element: bundleManager.ElementName) {
    this.element = element;
  }

  async withTag<T>(timeoutMs: number, operation: (info: tag.TagInfo) => Promise<T>): Promise<T> {
    const info = await this.discover(timeoutMs);
    try {
      return await operation(info);
    } catch (e) {
      throw NfcErrorMapper.from(e as Object);
    } finally {
      this.stop();
    }
  }

  cancel(): void {
    const abort = this.abort;
    this.abort = undefined;
    if (abort !== undefined) {
      abort(new NfcError(NfcErrorCode.CANCELLED, 'Cancelled'));
    } else {
      this.stop();
    }
  }

  private discover(timeoutMs: number): Promise<tag.TagInfo> {
    this.cancel();
    return new Promise<tag.TagInfo>((resolve, reject) => {
      let settled = false;
      let timer: number = 0;
      const fail = (error: NfcError): void => {
        if (settled) {
          return;
        }
        settled = true;
        clearTimeout(timer);
        this.abort = undefined;
        this.stop();
        reject(error);
      };
      this.abort = fail;
      timer = setTimeout(() => {
        fail(new NfcError(NfcErrorCode.TIMEOUT, 'No tag detected. Try again'));
      }, timeoutMs);
      try {
        tag.on('readerMode', this.element, DISCOVERY_TECHS, (err: BusinessError, info: tag.TagInfo) => {
          if (settled) {
            return;
          }
          if (err && err.code) {
            fail(NfcErrorMapper.from(err as Object));
            return;
          }
          settled = true;
          clearTimeout(timer);
          this.abort = undefined;
          resolve(info);
        });
      } catch (e) {
        fail(NfcErrorMapper.from(e as Object));
      }
    });
  }

  private stop(): void {
    try {
      tag.off('readerMode', this.element);
    } catch (e) {
      // off() throws if reader mode was not enabled; nothing to undo.
    }
  }
}
