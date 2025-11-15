@Component
export struct MyHeader {
  @Prop currentTabIndex: number = 0;
  @Link selectedDate: Date;
  @Link monthViewDate: Date;

  // 按钮逻辑
  private handlePrevClick() {
    if (this.currentTabIndex === 0) {
      const d = new Date(this.monthViewDate);
      d.setMonth(d.getMonth() - 1);
      this.monthViewDate = d;
    }
    else if (this.currentTabIndex === 1) {
      const d = new Date(this.selectedDate);
      d.setDate(d.getDate() - 7);
      this.selectedDate = d;
      this.monthViewDate = new Date(d);
    }
    else {
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

  build() {
    Row() {
      Button('<')
        .type(ButtonType.Circle)
        .backgroundColor('#ffeccc2f')
        .fontSize(20)
        .onClick(() => this.handlePrevClick())

      Blank()
      Text('日历')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Blank()

      Button('>')
        .type(ButtonType.Circle)
        .backgroundColor('#ffeccc2f')
        .fontSize(20)
        .onClick(() => this.handleNextClick())
    }
    .width('100%')
    .padding(12)
  }
}