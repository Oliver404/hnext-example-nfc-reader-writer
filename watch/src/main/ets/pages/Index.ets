import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Column({ space: 12 }) {
      Text('NFC Tool')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Button('Read tag')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: 'pages/ReadPage' });
        })

      Button('Write tag')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: 'pages/WritePage' });
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .justifyContent(FlexAlign.Center)
  }
}
