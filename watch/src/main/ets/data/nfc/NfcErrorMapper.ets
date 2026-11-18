import { BusinessError } from '@kit.BasicServicesKit';
import { NfcError, NfcErrorCode } from '../../domain/model/NfcError';

export class NfcErrorMapper {
  static from(e: Object): NfcError {
    if (e instanceof NfcError) {
      return e;
    }
    const be = e as BusinessError;
    switch (be.code) {
      case 201:
        return new NfcError(NfcErrorCode.PERMISSION_DENIED, 'NFC permission denied');
      case 801:
        return new NfcError(NfcErrorCode.NOT_SUPPORTED, 'NFC is not supported on this device');
      default:
        return new NfcError(NfcErrorCode.IO_FAILED, `NFC error ${be.code}: ${be.message}`);
    }
  }
}
