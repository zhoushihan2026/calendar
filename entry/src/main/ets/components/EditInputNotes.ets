@Component
export struct EditInputNotes {
  @Link formNotes: string;

  private handleNotesChange(value: string) {
    this.formNotes = value;
  }

  build() {
    Column() {
      Text('备注')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .backgroundColor('#fff8f8f8')
        .borderRadius(8)
        .width(50)
        .padding(5)
        .height(30)
        .textAlign(TextAlign.Center)
        .shadow({
          radius: 8,
          color: '#1A1A1A08',  // 轻微阴影
          offsetX: 0,
          offsetY: 2
        })

      TextInput({ placeholder: '请输入备注信息', text: this.formNotes })
        .onChange((value: string) => {
          this.handleNotesChange(value);
        })
        .height(50)
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top:12,bottom: 8 })
    }.backgroundColor('#fff3f3f3')
    .padding(15)
    .borderRadius(10)
    .margin({top:10,bottom:10})
  }
}