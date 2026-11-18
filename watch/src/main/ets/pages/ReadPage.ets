import { router } from '@kit.ArkUI';
import { NfcDetail, NfcNdefRecord } from '../domain/model/NfcTagInfo';
import { OperationState } from '../presentation/viewmodel/OperationState';
import { ReadViewModel } from '../presentation/viewmodel/ReadViewModel';

@Entry
@Component
struct ReadPage {
  @State vm: ReadViewModel = new ReadViewModel();

  aboutToDisappear(): void {
    this.vm.cancel();
  }

  @Builder
  Row2(label: string, value: string) {
    Column() {
      Text(label).fontSize(11).opacity(0.6)
      Text(value).fontSize(14)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column({ space: 8 }) {
        Text('Read tag').fontSize(16).fontWeight(FontWeight.Bold)

        if (this.vm.state === OperationState.WAITING) {
          LoadingProgress().width(32).height(32)
          Text('Hold a tag or card against the watch').fontSize(13).textAlign(TextAlign.Center)
          Button('Cancel').width('100%').onClick(() => this.vm.cancel())
        } else {
          if (this.vm.state === OperationState.ERROR) {
            Text(this.vm.error).fontSize(13).fontColor(Color.Red).textAlign(TextAlign.Center)
          }
          if (this.vm.state === OperationState.SUCCESS) {
            this.Row2('UID', this.vm.result.uid)
            this.Row2('Technologies', this.vm.result.technologies.join(', '))
            ForEach(this.vm.result.details, (d: NfcDetail) => {
              this.Row2(d.label, d.value)
            }, (d: NfcDetail, i: number) => `${i}-${d.label}`)

            if (this.vm.result.ndefType.length > 0) {
              this.Row2('NDEF', `${this.vm.result.ndefType}, ${this.vm.result.ndefSizeBytes} B, ` +
                (this.vm.result.ndefWritable ? 'writable' : 'read-only'))
              if (this.vm.result.ndefRecords.length === 0) {
                this.Row2('Records', 'None')
              }
            }
            ForEach(this.vm.result.ndefRecords, (r: NfcNdefRecord) => {
              this.Row2(r.title, r.content.length > 0 ? r.content : '(empty)')
            }, (r: NfcNdefRecord, i: number) => `${i}-${r.title}`)
          }
          Button(this.vm.state === OperationState.IDLE ? 'Start reading' : 'Read again')
            .width('100%')
            .onClick(() => {
              this.vm.start();
            })
          Button('Back').width('100%').onClick(() => router.back())
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }
}
