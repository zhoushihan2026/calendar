import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 在编辑页面中重新定义 CalendarEvent 接口
interface CalendarEvent {
  id: number,
  title: string,
  dateKey: string,
  startTime: string,
  endTime: string,
  reminderMinutes?: number,
  notes?: string,
  _timerId?: number
}

interface EditorParams {
  mode: 'create' | 'edit';
  date?: number;
  event?: string;
}

interface DatePickerResult {
  year: number;
  month: number;
  day: number;
}

interface TimePickerResult {
  hour: number;
  minute: number;
  second?: number;
}

@Entry
@Component
export struct EditPage {
  @State formTitle: string = '';
  @State formDate: Date = new Date();
  @State formStartMinutes: number = 9 * 60;
  @State formEndMinutes: number = 10 * 60;
  @State formReminderMinutes: number = 10;
  @State formNotes: string = '';
  @State isSaving: boolean = false; // 新增：防止重复保存

  private editingEvent?: CalendarEvent;
  private isNewEvent: boolean = true;
  // private nextEventId: number = 1; // 需要从主页面同步或使用全局状态

  aboutToAppear() {
    const params = router.getParams() as EditorParams;

    if (params.mode === 'create') {
      this.isNewEvent = true;
      if (params.date) {
        this.formDate = new Date(params.date);
      }
    } else if (params.mode === 'edit' && params.event) {
      this.isNewEvent = false;
      this.editingEvent = JSON.parse(params.event) as CalendarEvent;
      this.loadEventData(this.editingEvent);
    }
  }

  private loadEventData(event: CalendarEvent) {
    this.formTitle = event.title;
    const dateParts = event.dateKey.split('-');
    const y = Number(dateParts[0]);
    const m = Number(dateParts[1]);
    const d = Number(dateParts[2]);
    this.formDate = new Date(y, m - 1, d);
    this.formStartMinutes = this.parseTimeToMinutes(event.startTime);
    this.formEndMinutes = this.parseTimeToMinutes(event.endTime);
    this.formReminderMinutes = event.reminderMinutes ?? 10;
    this.formNotes = event.notes ?? '';
  }

  private parseTimeToMinutes(time: string): number {
    const parts = time.split(':');
    const h = parseInt(parts[0]);
    const m = parseInt(parts[1]);
    return h * 60 + m;
  }

  private minutesToTime(minutes: number): string {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
  }

  private formatDateKey(d: Date): string {
    const y = d.getFullYear();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  private createTimePickerDate(totalMinutes: number): Date {
    const base = new Date(this.formDate);
    const hour = Math.floor(totalMinutes / 60);
    const minute = totalMinutes % 60;
    const result = new Date(base);
    result.setHours(hour, minute, 0, 0);
    return result;
  }

  // private saveEvent() {
  //   const dateKey = this.formatDateKey(this.formDate);
  //   const startTime = this.minutesToTime(this.formStartMinutes);
  //   const endTime = this.minutesToTime(this.formEndMinutes);
  //
  //   if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
  //     promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
  //     return;
  //   }
  //
  //   // 这里需要实现保存逻辑，可以通过router.back()传递数据
  //   // 或者使用全局状态管理
  //
  //   promptAction.showToast({
  //     message: this.isNewEvent ? '创建成功' : '更新成功',
  //     duration: 1500
  //   });
  //
  //   router.back();
  // }

  //新的
  private saveEvent() {
    const dateKey = this.formatDateKey(this.formDate);
    const startTime = this.minutesToTime(this.formStartMinutes);
    const endTime = this.minutesToTime(this.formEndMinutes);

    if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
      promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
      return;
    }

    // 创建事件对象
    const eventData: CalendarEvent = {
      id: this.isNewEvent ? 0 : (this.editingEvent?.id || 0),
      title: this.formTitle,
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      reminderMinutes: this.formReminderMinutes,
      notes: this.formNotes
    };

    // 显示保存成功提示
    promptAction.showToast({
      message: this.isNewEvent ? '创建成功' : '更新成功',
      duration: 1500
    });

    // 返回数据到主页面
      router.back({
        url: 'pages/Index',
        params: {
          action: 'save',
          event: JSON.stringify(eventData)
        }
      });
  }

  private cancel() {
    router.back();
  }

  build() {
    Column() {
      // 头部导航
      Row() {
        Button('←')
          .type(ButtonType.Circle)
          .onClick(() => this.cancel())
          .backgroundColor('#ffe9b22e');

        Text(this.isNewEvent ? '新建日程' : '编辑日程')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Button('保存')
          .onClick(() => this.saveEvent())
          .fontSize(16)
          .backgroundColor('#ffe9b22e')
          .fontColor(Color.White)
          .padding({ left: 16, right: 16 })
          // .enabled(!this.isSaving);
      }
      .width('100%')
      .padding(12)
      .border({ width: { bottom: 1 }, color: '#f0f0f0' })

      // 表单内容
      Scroll() {
        Column() {
          // 标题
          Text('标题').fontSize(16).fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start).margin({bottom:10});
          TextInput({ placeholder: '请输入日程标题', text: this.formTitle })
            .onChange((value: string) => this.formTitle = value)
            .padding(12)
            .backgroundColor('#f8f8f8')
            .borderRadius(8)
            .margin({ bottom: 20 });

          // 日期选择
          Text('日期').fontSize(16).fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start).margin({bottom:10});
          DatePicker({
            start: new Date(2000, 0, 1),
            end: new Date(2100, 11, 31),
            selected: this.formDate
          })
            .onChange((value: DatePickerResult) => {
              this.formDate = new Date(value.year, value.month - 1, value.day);
            })
            .margin({ bottom: 20 });

          // 时间范围
          Text('时间').fontSize(16).fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start).margin({bottom:10});
          Row() {
            Column() {
              Text('开始时间').fontSize(14).opacity(0.8).margin({ bottom: 4 });
              TimePicker({
                selected: this.createTimePickerDate(this.formStartMinutes)
              })
                .useMilitaryTime(true)
                .onChange((value: TimePickerResult) => {
                  this.formStartMinutes = value.hour * 60 + value.minute;
                });
            }.layoutWeight(1)

            Column() {
              Text('结束时间').fontSize(14).opacity(0.8).margin({ bottom: 4 });
              TimePicker({
                selected: this.createTimePickerDate(this.formEndMinutes)
              })
                .useMilitaryTime(true)
                .onChange((value: TimePickerResult) => {
                  this.formEndMinutes = value.hour * 60 + value.minute;
                });
            }.layoutWeight(1)
          }
          .margin({ bottom: 20 })

          // 提醒设置
          Text('提醒').fontSize(16).fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start).margin({bottom:10});
          Slider({
            min: 0,
            max: 120,
            value: this.formReminderMinutes,
            step: 5
          })
            .showSteps(true)
            .onChange((v: number) => this.formReminderMinutes = Math.round(v));
          Text(`${this.formReminderMinutes} 分钟`).fontSize(14).opacity(0.7).margin({ bottom: 20 });

          // 备注
          Text('备注').fontSize(16).fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start).margin({bottom:10});
          TextInput({ placeholder: '可选备注信息', text: this.formNotes })
            .onChange((value: string) => this.formNotes = value)
            .height(100)
            .padding(12)
            .backgroundColor('#f8f8f8')
            .borderRadius(8);
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}