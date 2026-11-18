import { NfcRecordType } from './NfcRecordType';

/**
 * What to write. `extra` meaning depends on `type`:
 * TEXT: language code (default "en") | SMS: message body | MIME: MIME type |
 * EXTERNAL: "domain:type". Unused otherwise.
 */
export class NfcWriteRequest {
  type: NfcRecordType;
  value: string;
  extra: string;

  constructor(type: NfcRecordType, value: string, extra: string = '') {
    this.type = type;
    this.value = value;
    this.extra = extra;
  }
}
