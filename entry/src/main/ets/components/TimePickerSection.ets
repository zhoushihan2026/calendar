// TimePickerSection
@Component
export struct TimePickerSection {
  @Link formStartMinutes: number;
  @Link formEndMinutes: number;
  @Prop formDate: Date;

  private createTimePickerDate(totalMinutes: number): Date {
    const base = new Date(this.formDate);
    const hour = Math.floor(totalMinutes / 60);
    const minute = totalMinutes % 60;
    const result = new Date(base);
    result.setHours(hour, minute, 0, 0);
    return result;
  }

  private handleStartTimeChange(value: TimePickerResult) {
    const minutes = value.hour * 60 + value.minute;
    // 直接更新通过 @Link 绑定的数据
    this.formStartMinutes = minutes;
  }

  private handleEndTimeChange(value: TimePickerResult) {
    const minutes = value.hour * 60 + value.minute;
    // 直接更新通过 @Link 绑定的数据
    this.formEndMinutes = minutes;
  }

  build() {
    Column() {
      Text('时间')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 });

      Row() {
        Column() {
          Text('开始时间')
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 4 });
          TimePicker({
            selected: this.createTimePickerDate(this.formStartMinutes)
          })
            .useMilitaryTime(true)
            .onChange((value: TimePickerResult) => {
              this.handleStartTimeChange(value);
            });
        }.layoutWeight(1)

        Column() {
          Text('结束时间')
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 4 });
          TimePicker({
            selected: this.createTimePickerDate(this.formEndMinutes)
          })
            .useMilitaryTime(true)
            .onChange((value: TimePickerResult) => {
              this.handleEndTimeChange(value);
            });
        }.layoutWeight(1)
      }
      .margin({ bottom: 20 })
    }
  }
}