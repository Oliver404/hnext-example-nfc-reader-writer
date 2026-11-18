import { NfcRecordType } from '../../domain/model/NfcRecordType';

/** Display strings for each writable record type (kept out of the domain layer). */
export class RecordTypeUi {
  static label(type: NfcRecordType): string {
    switch (type) {
      case NfcRecordType.TEXT: return 'Text';
      case NfcRecordType.URL: return 'URL';
      case NfcRecordType.PHONE: return 'Phone';
      case NfcRecordType.EMAIL: return 'Email';
      case NfcRecordType.SMS: return 'SMS';
      case NfcRecordType.GEO: return 'Location';
      case NfcRecordType.MIME: return 'MIME data';
      case NfcRecordType.APPLICATION: return 'App';
      case NfcRecordType.EXTERNAL: return 'External';
      default: return '';
    }
  }

  static valueHint(type: NfcRecordType): string {
    switch (type) {
      case NfcRecordType.TEXT: return 'Text';
      case NfcRecordType.URL: return 'https://example.com';
      case NfcRecordType.PHONE: return '+15551234567';
      case NfcRecordType.EMAIL: return 'name@example.com';
      case NfcRecordType.SMS: return 'Phone number';
      case NfcRecordType.GEO: return 'lat,lon (19.43,-99.13)';
      case NfcRecordType.MIME: return 'Data';
      case NfcRecordType.APPLICATION: return 'Bundle name';
      case NfcRecordType.EXTERNAL: return 'Data';
      default: return '';
    }
  }

  /** Empty string = this type has no secondary field. */
  static extraHint(type: NfcRecordType): string {
    switch (type) {
      case NfcRecordType.TEXT: return 'Language (en)';
      case NfcRecordType.SMS: return 'Message (optional)';
      case NfcRecordType.MIME: return 'MIME type (text/plain)';
      case NfcRecordType.EXTERNAL: return 'domain:type';
      default: return '';
    }
  }
}
