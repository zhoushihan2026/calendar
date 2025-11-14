@Component
export struct EditInputTitle {
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

      TextInput({ placeholder: '请输入日程标题', text: this.formTitle })
        .onChange((value: string) => {
          this.handleTitleChange(value);
        })
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top:10,bottom: 8 });
    }.backgroundColor('#fff3f3f3')
    .padding(15)
    .borderRadius(10)
    .margin({bottom:10})
  }
}