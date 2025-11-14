@Component
export struct EditSelectDate {
  @Link formDate: Date;
  private debounceTimer: number | null = null;

  private handleDateChange(value: DatePickerResult) {
    console.log('DatePicker 返回:', value);

    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer);
    }

    this.debounceTimer = setTimeout(() => {
      if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
        const newDate = new Date(value.year, value.month , value.day);
        this.formDate = newDate;
      }
      this.debounceTimer = null;
    }, 300) as number;
  }

  build() {
    Column() {
      Text('日期')
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

      DatePicker({
        start: new Date(2000, 0, 1),
        end: new Date(2100, 11, 31),
        selected: this.formDate
      })
        .onChange((value: DatePickerResult) => {
          this.handleDateChange(value);
        })
        .margin({ top:12,bottom: 8 });
    }.backgroundColor('#fff3f3f3')
    .padding(15)
    .borderRadius(10)
    .margin({top:10,bottom:10})
  }
}