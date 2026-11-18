import { tag } from '@kit.ConnectivityKit';
import { NfcNdefRecord } from '../../domain/model/NfcTagInfo';
import { NfcRecordType } from '../../domain/model/NfcRecordType';
import { NfcWriteRequest } from '../../domain/model/NfcWriteRequest';
import { NfcBytes } from './NfcBytes';

// NFC Forum URI Record Type Definition, abbreviation table.
const URI_PREFIXES: string[] = [
  '', 'http://www.', 'https://www.', 'http://', 'https://', 'tel:', 'mailto:',
  'ftp://anonymous:anonymous@', 'ftp://ftp.', 'ftps://', 'sftp://', 'smb://', 'nfs://',
  'ftp://', 'dav://', 'news:', 'telnet://', 'imap:', 'rtsp://', 'urn:', 'pop:', 'sip:',
  'sips:', 'tftp:', 'btspp://', 'btl2cap://', 'btgoep://', 'tcpobex://', 'irdaobex://',
  'file://', 'urn:epc:id:', 'urn:epc:tag:', 'urn:epc:pat:', 'urn:epc:raw:', 'urn:epc:',
  'urn:nfc:'
];

const TNF_EMPTY = 0x0;
const TNF_WELL_KNOWN = 0x1;
const TNF_MEDIA = 0x2;
const TNF_ABSOLUTE_URI = 0x3;
const TNF_EXTERNAL = 0x4;

export class NfcRecordCodec {
  /** Domain request -> NDEF record. */
  static encode(request: NfcWriteRequest): tag.NdefRecord {
    const value = request.value.trim();
    const extra = request.extra.trim();
    switch (request.type) {
      case NfcRecordType.TEXT:
        return tag.ndef.makeTextRecord(request.value, extra.length > 0 ? extra : 'en');
      case NfcRecordType.URL:
        return tag.ndef.makeUriRecord(value.indexOf(':') > 0 ? value : `https://${value}`);
      case NfcRecordType.PHONE:
        return tag.ndef.makeUriRecord(`tel:${value}`);
      case NfcRecordType.EMAIL:
        return tag.ndef.makeUriRecord(`mailto:${value}`);
      case NfcRecordType.SMS:
        return tag.ndef.makeUriRecord(extra.length > 0 ? `sms:${value}?body=${encodeURIComponent(extra)}` : `sms:${value}`);
      case NfcRecordType.GEO:
        return tag.ndef.makeUriRecord(`geo:${value.replace(/\s+/g, '')}`);
      case NfcRecordType.MIME:
        return tag.ndef.makeMimeRecord(extra, NfcBytes.utf8Encode(request.value));
      case NfcRecordType.APPLICATION:
        return tag.ndef.makeApplicationRecord(value);
      case NfcRecordType.EXTERNAL: {
        const sep = extra.indexOf(':');
        return tag.ndef.makeExternalRecord(extra.substring(0, sep), extra.substring(sep + 1), NfcBytes.utf8Encode(request.value));
      }
      default:
        throw new Error('Unsupported record type');
    }
  }

  /** NDEF record -> domain record. */
  static decode(record: tag.NdefRecord): NfcNdefRecord {
    switch (record.tnf) {
      case TNF_EMPTY:
        return new NfcNdefRecord(NfcRecordType.EMPTY, 'Empty', '');
      case TNF_WELL_KNOWN:
        return NfcRecordCodec.decodeWellKnown(record);
      case TNF_MEDIA: {
        const mime = NfcBytes.utf8Decode(record.rtdType);
        return new NfcNdefRecord(NfcRecordType.MIME, `MIME ${mime}`, NfcBytes.textOrHex(record.payload));
      }
      case TNF_ABSOLUTE_URI:
        return NfcRecordCodec.classifyUri(NfcBytes.utf8Decode(record.rtdType));
      case TNF_EXTERNAL: {
        const type = NfcBytes.utf8Decode(record.rtdType);
        const content = NfcBytes.textOrHex(record.payload);
        if (type.endsWith(':pkg')) {
          return new NfcNdefRecord(NfcRecordType.APPLICATION, 'Application', content);
        }
        return new NfcNdefRecord(NfcRecordType.EXTERNAL, `External ${type}`, content);
      }
      default:
        return new NfcNdefRecord(NfcRecordType.UNKNOWN, 'Unknown', NfcBytes.toHex(record.payload, ' '));
    }
  }

  private static decodeWellKnown(record: tag.NdefRecord): NfcNdefRecord {
    const payload = record.payload;
    const rtd = record.rtdType;
    if (rtd.length === 1 && rtd[0] === 0x54 && payload.length > 0) {
      const status = payload[0];
      const langLen = status & 0x3F;
      const lang = NfcBytes.utf8Decode(payload.slice(1, 1 + langLen));
      const body = payload.slice(1 + langLen);
      const text = (status & 0x80) !== 0 ? NfcBytes.utf16beDecode(body) : NfcBytes.utf8Decode(body);
      return new NfcNdefRecord(NfcRecordType.TEXT, `Text (${lang})`, text);
    }
    if (rtd.length === 1 && rtd[0] === 0x55 && payload.length > 0) {
      const prefix = payload[0] < URI_PREFIXES.length ? URI_PREFIXES[payload[0]] : '';
      return NfcRecordCodec.classifyUri(prefix + NfcBytes.utf8Decode(payload.slice(1)));
    }
    return new NfcNdefRecord(NfcRecordType.UNKNOWN, `Well-known ${NfcBytes.utf8Decode(rtd)}`, NfcBytes.textOrHex(payload));
  }

  private static classifyUri(uri: string): NfcNdefRecord {
    const lower = uri.toLowerCase();
    if (lower.startsWith('tel:')) {
      return new NfcNdefRecord(NfcRecordType.PHONE, 'Phone', uri.substring(4));
    }
    if (lower.startsWith('mailto:')) {
      return new NfcNdefRecord(NfcRecordType.EMAIL, 'Email', uri.substring(7));
    }
    if (lower.startsWith('sms:') || lower.startsWith('smsto:')) {
      return new NfcNdefRecord(NfcRecordType.SMS, 'SMS', uri.substring(uri.indexOf(':') + 1));
    }
    if (lower.startsWith('geo:')) {
      return new NfcNdefRecord(NfcRecordType.GEO, 'Location', uri.substring(4));
    }
    return new NfcNdefRecord(NfcRecordType.URL, 'URL', uri);
  }
}
