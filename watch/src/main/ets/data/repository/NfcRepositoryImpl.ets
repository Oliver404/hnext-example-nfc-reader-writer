import { nfcController, tag } from '@kit.ConnectivityKit';
import { NfcTagInfo } from '../../domain/model/NfcTagInfo';
import { NfcWriteRequest } from '../../domain/model/NfcWriteRequest';
import { NfcRepository } from '../../domain/repository/NfcRepository';
import { NfcDiscoveryDataSource } from '../nfc/NfcDiscoveryDataSource';
import { NfcRecordCodec } from '../nfc/NfcRecordCodec';
import { NfcTagReader } from '../nfc/NfcTagReader';
import { NfcTagWriter } from '../nfc/NfcTagWriter';

export class NfcRepositoryImpl implements NfcRepository {
  private readonly discovery: NfcDiscoveryDataSource;
  private readonly reader: NfcTagReader = new NfcTagReader();
  private readonly writer: NfcTagWriter = new NfcTagWriter();

  constructor(discovery: NfcDiscoveryDataSource) {
    this.discovery = discovery;
  }

  isNfcAvailable(): boolean {
    return nfcController.isNfcAvailable();
  }

  isNfcEnabled(): boolean {
    return nfcController.isNfcOpen();
  }

  readTag(timeoutMs: number): Promise<NfcTagInfo> {
    return this.discovery.withTag<NfcTagInfo>(timeoutMs, (info: tag.TagInfo) => this.reader.read(info));
  }

  writeTag(request: NfcWriteRequest, timeoutMs: number): Promise<void> {
    const record = NfcRecordCodec.encode(request);
    return this.discovery.withTag<void>(timeoutMs, (info: tag.TagInfo) => this.writer.write(info, [record]));
  }

  cancel(): void {
    this.discovery.cancel();
  }
}
