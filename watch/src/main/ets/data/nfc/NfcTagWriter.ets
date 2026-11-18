import { tag } from '@kit.ConnectivityKit';
import { NfcError, NfcErrorCode } from '../../domain/model/NfcError';

/** Writes an NDEF message to an NDEF tag, or formats a blank formatable tag with it. */
export class NfcTagWriter {
  async write(info: tag.TagInfo, records: tag.NdefRecord[]): Promise<void> {
    const message = tag.ndef.createNdefMessage(records);
    const techs: number[] = info.technology;

    if (techs.includes(tag.NDEF)) {
      const ndef = tag.getNdef(info);
      if (!ndef.isNdefWritable()) {
        throw new NfcError(NfcErrorCode.READ_ONLY, 'This tag is read-only');
      }
      try {
        ndef.connect();
        await ndef.writeNdef(message);
      } finally {
        NfcTagWriter.release(ndef);
      }
      return;
    }

    if (techs.includes(tag.NDEF_FORMATABLE)) {
      const formatable = tag.getNdefFormatable(info);
      try {
        formatable.connect();
        await formatable.format(message);
      } finally {
        NfcTagWriter.release(formatable);
      }
      return;
    }

    throw new NfcError(NfcErrorCode.UNSUPPORTED_TAG, 'This tag does not support NDEF writing');
  }

  private static release(session: tag.TagSession): void {
    try {
      session.resetConnection();
    } catch (e) {
      // Connection may already be gone.
    }
  }
}
