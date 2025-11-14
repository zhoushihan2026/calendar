// TitleInput
@Component
export struct TitleInput {
  @Link formTitle: string;

  private handleTitleChange(value: string) {
    // 直接更新通过 @Link 绑定的数据
    this.formTitle = value;
  }

  build() {
    Column() {
      Text('标题')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 });

      TextInput({ placeholder: '请输入日程标题', text: this.formTitle })
        .onChange((value: string) => {
          this.handleTitleChange(value);
        })
        .padding(12)
        .backgroundColor('#f8f8f8')
        .borderRadius(8)
        .margin({ bottom: 20 });
    }
  }
}