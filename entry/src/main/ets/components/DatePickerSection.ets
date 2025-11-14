@Component
export struct DatePickerSection {
  @Link formDate: Date;

  private handleDateChange(value: DatePickerResult) {
    // 添加类型检查，确保值不是 undefined
    if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
      const newDate = new Date(value.year, value.month - 1, value.day);
      // 直接更新通过 @Link 绑定的数据
      this.formDate = newDate;
    }
  }

  build() {
    Column() {
      Text('日期')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 });

      DatePicker({
        start: new Date(2000, 0, 1),
        end: new Date(2100, 11, 31),
        selected: this.formDate
      })
        .onChange((value: DatePickerResult) => {
          this.handleDateChange(value);
        })
        .margin({ bottom: 20 });
    }
  }
}