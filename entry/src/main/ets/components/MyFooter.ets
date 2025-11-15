import router from '@ohos.router';

@Component
export struct MyFooter {
  @Prop defaultToday: Date;  // 传递当前日期作为默认值

  private handleAddClick() {
    router.pushUrl({
      url: 'pages/EditPage',
      params: {
        mode: 'create',
        date: this.defaultToday.getTime()
      }
    });
  }

  build() {
    Button('+')
      .type(ButtonType.Circle)
      .backgroundColor('#ffeccc2f')
      .fontColor(Color.White)
      .fontSize(25)
      .position({ x: '300.00vp', y: '680.00vp' })
      .onClick(() => {this.handleAddClick();})
  }
}