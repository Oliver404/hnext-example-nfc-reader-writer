import { router } from '@kit.ArkUI';
import { RecordTypeUi } from '../presentation/model/RecordTypeUi';
import { OperationState } from '../presentation/viewmodel/OperationState';
import { WriteViewModel } from '../presentation/viewmodel/WriteViewModel';

@Entry
@Component
struct WritePage {
  @State vm: WriteViewModel = new WriteViewModel();

  aboutToDisappear(): void {
    this.vm.cancel();
  }

  build() {
    Scroll() {
      Column({ space: 8 }) {
        Text('Write tag').fontSize(16).fontWeight(FontWeight.Bold)

        if (this.vm.state === OperationState.WAITING) {
          LoadingProgress().width(32).height(32)
          Text('Hold a tag or card against the watch').fontSize(13).textAlign(TextAlign.Center)
          Button('Cancel').width('100%').onClick(() => this.vm.cancel())
        } else {
          Button(`Type: ${RecordTypeUi.label(this.vm.type)}`)
            .width('100%')
            .onClick(() => this.vm.nextType())

          TextInput({ text: this.vm.value, placeholder: RecordTypeUi.valueHint(this.vm.type) })
            .onChange((v: string) => {
              this.vm.value = v;
            })

          if (RecordTypeUi.extraHint(this.vm.type).length > 0) {
            TextInput({ text: this.vm.extra, placeholder: RecordTypeUi.extraHint(this.vm.type) })
              .onChange((v: string) => {
                this.vm.extra = v;
              })
          }

          if (this.vm.state === OperationState.ERROR) {
            Text(this.vm.error).fontSize(13).fontColor(Color.Red).textAlign(TextAlign.Center)
          }
          if (this.vm.state === OperationState.SUCCESS) {
            Text('Written successfully').fontSize(13).fontColor(Color.Green)
          }

          Button('Write to tag')
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
