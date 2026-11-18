import { tag } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { NfcTagInfo } from '../../domain/model/NfcTagInfo';
import { NfcBytes } from './NfcBytes';
import { NfcRecordCodec } from './NfcRecordCodec';

const TAG = 'NfcTagReader';
const DOMAIN = 0x0000;
const MIFARE_DEFAULT_KEY: number[] = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];

/** Reads as much as possible from every technology the tag exposes. */
export class NfcTagReader {
  async read(info: tag.TagInfo): Promise<NfcTagInfo> {
    const result = new NfcTagInfo();
    result.uid = NfcBytes.toHex(info.uid);
    const techs: number[] = info.technology;
    for (const t of techs) {
      result.technologies.push(NfcTagReader.techName(t));
    }

    if (techs.includes(tag.NFC_A)) {
      this.guard('NFC-A', () => {
        const a = tag.getNfcA(info);
        result.addDetail('ATQA', NfcBytes.toHex(a.getAtqa()));
        result.addDetail('SAK', `0x${a.getSak().toString(16).toUpperCase()}`);
      });
    }
    if (techs.includes(tag.NFC_B)) {
      this.guard('NFC-B', () => {
        const b = tag.getNfcB(info);
        result.addDetail('App data', NfcBytes.toHex(b.getRespAppData()));
        result.addDetail('Protocol', NfcBytes.toHex(b.getRespProtocol()));
      });
    }
    if (techs.includes(tag.NFC_F)) {
      this.guard('NFC-F', () => {
        const f = tag.getNfcF(info);
        result.addDetail('System code', NfcBytes.toHex(f.getSystemCode()));
        result.addDetail('PMm', NfcBytes.toHex(f.getPmm()));
      });
    }
    if (techs.includes(tag.NFC_V)) {
      this.guard('NFC-V', () => {
        const v = tag.getNfcV(info);
        result.addDetail('Response flags', `0x${v.getResponseFlags().toString(16).toUpperCase()}`);
        result.addDetail('DSF ID', `0x${v.getDsfId().toString(16).toUpperCase()}`);
      });
    }
    if (techs.includes(tag.ISO_DEP)) {
      this.guard('ISO-DEP', () => {
        const iso = tag.getIsoDep(info);
        const hist = iso.getHistoricalBytes();
        const hi = iso.getHiLayerResponse();
        if (hist.length > 0) {
          result.addDetail('Historical bytes', NfcBytes.toHex(hist));
        }
        if (hi.length > 0) {
          result.addDetail('Hi-layer resp.', NfcBytes.toHex(hi));
        }
      });
    }
    if (techs.includes(tag.MIFARE_ULTRALIGHT)) {
      await this.readUltralight(info, result);
    }
    if (techs.includes(tag.MIFARE_CLASSIC)) {
      await this.readClassic(info, result);
    }
    if (techs.includes(tag.NDEF)) {
      await this.readNdef(info, result);
    }
    return result;
  }

  private async readNdef(info: tag.TagInfo, out: NfcTagInfo): Promise<void> {
    let ndef: tag.NdefTag;
    try {
      ndef = tag.getNdef(info);
      out.ndefType = ndef.getNdefTagTypeString(ndef.getNdefTagType());
      out.ndefWritable = ndef.isNdefWritable();
    } catch (e) {
      this.skip('NDEF', e as Object);
      return;
    }
    let message: tag.NdefMessage | undefined = undefined;
    try {
      ndef.connect();
      message = await ndef.readNdef();
    } catch (e) {
      this.skip('NDEF read', e as Object);
      try {
        message = ndef.getNdefMessage(); // cached copy from discovery
      } catch (e2) {
        this.skip('NDEF cached', e2 as Object);
      }
    } finally {
      this.release(ndef);
    }
    if (message !== undefined) {
      const records = message.getNdefRecords();
      for (const r of records) {
        out.ndefRecords.push(NfcRecordCodec.decode(r));
      }
      out.ndefSizeBytes = tag.ndef.messageToBytes(message).length;
    }
  }

  private async readUltralight(info: tag.TagInfo, out: NfcTagInfo): Promise<void> {
    let ul: tag.MifareUltralightTag;
    try {
      ul = tag.getMifareUltralight(info);
      out.addDetail('Ultralight', ul.getType() === tag.MifareUltralightType.TYPE_ULTRALIGHT_C ? 'Ultralight C' : 'Ultralight');
    } catch (e) {
      this.skip('Ultralight', e as Object);
      return;
    }
    try {
      ul.connect();
      const pages = await ul.readMultiplePages(0); // pages 0-3 (16 bytes)
      out.addDetail('Pages 0-3', NfcBytes.toHex(pages, ' '));
    } catch (e) {
      this.skip('Ultralight read', e as Object);
    } finally {
      this.release(ul);
    }
  }

  private async readClassic(info: tag.TagInfo, out: NfcTagInfo): Promise<void> {
    let mc: tag.MifareClassicTag;
    try {
      mc = tag.getMifareClassic(info);
      out.addDetail('Classic type', NfcTagReader.classicTypeName(mc.getType()));
      out.addDetail('Size', `${mc.getTagSize()} B, ${mc.getSectorCount()} sectors`);
    } catch (e) {
      this.skip('Classic', e as Object);
      return;
    }
    try {
      mc.connect();
      await mc.authenticateSector(0, MIFARE_DEFAULT_KEY, true);
      const block0 = await mc.readSingleBlock(0);
      out.addDetail('Block 0', NfcBytes.toHex(block0, ' '));
    } catch (e) {
      out.addDetail('Data', 'Locked (needs sector key)');
      this.skip('Classic read', e as Object);
    } finally {
      this.release(mc);
    }
  }

  private guard(name: string, block: () => void): void {
    try {
      block();
    } catch (e) {
      this.skip(name, e as Object);
    }
  }

  private release(session: tag.TagSession): void {
    try {
      session.resetConnection();
    } catch (e) {
      // Connection may never have been established.
    }
  }

  private skip(what: string, e: Object): void {
    hilog.warn(DOMAIN, TAG, '%{public}s skipped: %{public}s', what, JSON.stringify(e));
  }

  static techName(t: number): string {
    switch (t) {
      case tag.NFC_A: return 'NFC-A';
      case tag.NFC_B: return 'NFC-B';
      case tag.ISO_DEP: return 'ISO-DEP';
      case tag.NFC_F: return 'NFC-F';
      case tag.NFC_V: return 'NFC-V';
      case tag.NDEF: return 'NDEF';
      case tag.NDEF_FORMATABLE: return 'NDEF-formatable';
      case tag.MIFARE_CLASSIC: return 'MIFARE Classic';
      case tag.MIFARE_ULTRALIGHT: return 'MIFARE Ultralight';
      default: return `Tech ${t}`;
    }
  }

  private static classicTypeName(t: tag.MifareClassicType): string {
    switch (t) {
      case tag.MifareClassicType.TYPE_CLASSIC: return 'Classic';
      case tag.MifareClassicType.TYPE_PLUS: return 'Plus';
      case tag.MifareClassicType.TYPE_PRO: return 'Pro';
      default: return 'Unknown';
    }
  }
}
