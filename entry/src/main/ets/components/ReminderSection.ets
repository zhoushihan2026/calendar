@Component
export struct ReminderSection {
  @Link formReminderMinutes: number;

  private handleReminderChange(v: number) {
    const minutes = Math.round(v);
    // 直接更新通过 @Link 绑定的数据
    this.formReminderMinutes = minutes;
  }

  build() {
    Column() {
      Text('提醒')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 });

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
        .margin({ bottom: 20 });
    }
  }
}