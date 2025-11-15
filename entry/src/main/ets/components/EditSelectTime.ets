@Component
export struct EditSelectTime {
  @Link formStartMinutes: number;
  @Link formEndMinutes: number;
  @Prop formDate: Date;

  private minutesToDate(minutes: number): Date {
    const date = new Date(this.formDate);
    const hour = Math.floor(minutes / 60);
    const minute = minutes % 60;
    date.setHours(hour, minute, 0, 0);
    return date;
  }
  private handleStartTimeChange(value: TimePickerResult) {
    const minutes = value.hour * 60 + value.minute;
    this.formStartMinutes = minutes;
  }
  private handleEndTimeChange(value: TimePickerResult) {
    const minutes = value.hour * 60 + value.minute;
    this.formEndMinutes = minutes;
  }

  build() {
    Column() {
      Text('时间')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .backgroundColor('#fff8f8f8')
        .borderRadius(8)
        .padding(8)
        .textAlign(TextAlign.Center)
        .shadow({
          radius: 8,
          color: '#1A1A1A08',
          offsetX: 0,
          offsetY: 2
        })

      Row() {
        Column() {
          Text('开始时间')
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 8 });
          TimePicker({
            selected: this.minutesToDate(this.formStartMinutes)
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
            .margin({ bottom: 8 });
          TimePicker({
            selected: this.minutesToDate(this.formEndMinutes)
          })
            .useMilitaryTime(true)
            .onChange((value: TimePickerResult) => {
              this.handleEndTimeChange(value);
            });
        }.layoutWeight(1)
      }
      .margin({ top:12,bottom: 8 });
    }.backgroundColor('#fff3f3f3')
    .padding(15)
    .borderRadius(10)
    .margin({top:10,bottom:10})
  }
}