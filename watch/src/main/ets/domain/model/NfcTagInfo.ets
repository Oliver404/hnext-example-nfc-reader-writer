import { NfcRecordType } from './NfcRecordType';

export class NfcDetail {
  label: string;
  value: string;

  constructor(label: string, value: string) {
    this.label = label;
    this.value = value;
  }
}

export class NfcNdefRecord {
  type: NfcRecordType;
  /** Human-readable kind, e.g. "Text", "URL", "MIME text/plain". */
  title: string;
  content: string;

  constructor(type: NfcRecordType, title: string, content: string) {
    this.type = type;
    this.title = title;
    this.content = content;
  }
}

/** Everything the app learned from one tag/card. */
export class NfcTagInfo {
  uid: string = '';
  technologies: string[] = [];
  details: NfcDetail[] = [];
  ndefType: string = '';
  ndefWritable: boolean = false;
  ndefSizeBytes: number = 0;
  ndefRecords: NfcNdefRecord[] = [];

  addDetail(label: string, value: string): void {
    this.details.push(new NfcDetail(label, value));
  }
}
