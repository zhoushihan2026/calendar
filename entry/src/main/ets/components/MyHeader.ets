@Component
export struct MyHeader {
  @State currentTabIndex: number = 0;
  // @State selectedDate: Date = new Date();
  // @State monthViewDate: Date = new Date();
  @Link selectedDate: Date;
  @Link monthViewDate: Date;

  // private onPrevClick: () => void = () => {};
  // private onNextClick: () => void = () => {};

  private handlePrevClick() {
    if (this.currentTabIndex === 0) {
      // 直接修改 @Link 绑定的数据
      const d = new Date(this.monthViewDate);
      d.setMonth(d.getMonth() - 1);
      this.monthViewDate = d;
    } else if (this.currentTabIndex === 1) {
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() - 7);
      this.selectedDate = d;
      this.monthViewDate = new Date(d);
    } else {
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() - 1);
      this.selectedDate = d;
      this.monthViewDate = new Date(d);
    }
  }
  private handleNextClick() {
    if (this.currentTabIndex === 0) {
      const d = new Date(this.monthViewDate);
      d.setMonth(d.getMonth() + 1);
      this.monthViewDate = d;
    } else if (this.currentTabIndex === 1) {
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() + 7);
      this.selectedDate = d;
      this.monthViewDate = new Date(d);
    } else {
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() + 1);
      this.selectedDate = d;
      this.monthViewDate = new Date(d);
    }
  }

  aboutToAppear() {
    // 初始化回调函数
  }

  build() {
    Row() {
      Button('<')
        .type(ButtonType.Circle)
        .backgroundColor('#ffe9b22e')
        .onClick(() => this.handlePrevClick())

      Blank()
      Text('日历')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Blank()

      Button('>')
        .type(ButtonType.Circle)
        .backgroundColor('#ffe9b22e')
        .onClick(() => this.handleNextClick())
    }
    .width('100%')
    .padding(12)
  }
}