/** Kinds of NDEF payloads the app can read and/or write. */
export enum NfcRecordType {
  TEXT,
  URL,
  PHONE,
  EMAIL,
  SMS,
  GEO,
  MIME,
  APPLICATION,
  EXTERNAL,
  // Read-only classifications
  EMPTY,
  UNKNOWN
}

/** Record types that can be written to a tag. */
export const WRITABLE_RECORD_TYPES: NfcRecordType[] = [
  NfcRecordType.TEXT,
  NfcRecordType.URL,
  NfcRecordType.PHONE,
  NfcRecordType.EMAIL,
  NfcRecordType.SMS,
  NfcRecordType.GEO,
  NfcRecordType.MIME,
  NfcRecordType.APPLICATION,
  NfcRecordType.EXTERNAL
];
