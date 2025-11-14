import router from '@ohos.router';

@Component
export struct MyFooter {
  @Prop selectedDate: Date;  // 只需要传递选中的日期

  private handleAddClick() {
    router.pushUrl({
      url: 'pages/EditPage',
      params: {
        mode: 'create',
        date: this.selectedDate.getTime()
      }
    });
  }

  build() {
    Button('+')
      .type(ButtonType.Capsule)
      .backgroundColor('#ffe9b22e')
      .fontColor(Color.White)
      .position({ x: '300.00vp', y: '680.00vp' })
      .onClick(() => {
        this.handleAddClick();
      })
  }
}