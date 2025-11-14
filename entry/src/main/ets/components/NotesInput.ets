// NotesInput
@Component
export struct NotesInput {
  @Link formNotes: string;

  private handleNotesChange(value: string) {
    // 直接更新通过 @Link 绑定的数据
    this.formNotes = value;
  }

  build() {
    Column() {
      Text('备注')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 });

      TextInput({ placeholder: '可选备注信息', text: this.formNotes })
        .onChange((value: string) => {
          this.handleNotesChange(value);
        })
        .height(100)
        .padding(12)
        .backgroundColor('#f8f8f8')
        .borderRadius(8);
    }
  }
}