@Component
export struct EditReminder {
  @Link formReminderMinutes: number;

  private handleReminderChange(v: number) {
    const minutes = Math.round(v);
    this.formReminderMinutes = minutes;
  }

  build() {
    Column() {
      Text('提醒')
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

      Slider({
        min: 0,
        max: 120,
        value: this.formReminderMinutes,
        step: 5
      })
        .showSteps(true)
        .onChange((v: number) => {
          this.handleReminderChange(v);
        });

      Text(`${this.formReminderMinutes} 分钟`)
        .fontSize(14)
        .opacity(0.7)
        .margin({ bottom: 8 });
    }.backgroundColor('#fff3f3f3')
    .padding(15)
    .borderRadius(10)
    .margin({top:10,bottom:10})
  }
}