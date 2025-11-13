import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

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

interface CalendarEvent {
  id: number,
  title: string,
  dateKey: string, // YYYY-MM-DD
  startTime: string, // HH:mm
  endTime: string,   // HH:mm
  reminderMinutes?: number, // minutes before start
  notes?: string,
  _timerId?: number
}

// 在接口定义区域添加新的接口
interface RouterParams {
  action?: string;
  event?: string;
}

function formatDateKey(d: Date): string {
  const y = d.getFullYear();
  const m = (d.getMonth() + 1).toString().padStart(2, '0');
  const day = d.getDate().toString().padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function parseTimeToMinutes(time: string): number {
  const parts = time.split(':');
  const h = parseInt(parts[0]);
  const m = parseInt(parts[1]);
  return h * 60 + m;
}

function minutesToTime(minutes: number): string {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
}

function getMonthGridDates(viewDate: Date): Date[] {
  const firstOfMonth = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1);
  const startDay = firstOfMonth.getDay(); // 0=Sun ... 6=Sat
  const startDate = new Date(firstOfMonth);
  startDate.setDate(firstOfMonth.getDate() - startDay);
  const result: Date[] = [];
  for (let i = 0; i < 42; i++) {
    const d = new Date(startDate);
    d.setDate(startDate.getDate() + i);
    result.push(d);
  }
  return result;
}

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0; // 0: Month, 1: Week, 2: Day
  @State today: Date = new Date();
  @State selectedDate: Date = new Date();
  @State monthViewDate: Date = new Date(); // which month to display
  @State events: CalendarEvent[] = [];
  @State nextEventId: number = 1;

  aboutToAppear() {
    // 新增：页面显示时刷新数据
    this.refreshEvents();
  }

  private refreshEvents() {
    // 可以从本地存储加载事件
    // 这里保持原有逻辑
  }

  // @State showEditor: boolean = false;
  // @State editingEventId?: number = undefined; // undefined for new
  //
  // // Editor states
  // @State formTitle: string = '';
  // @State formDate: Date = new Date();
  // @State formStartMinutes: number = 9 * 60;
  // @State formEndMinutes: number = 10 * 60;
  // @State formReminderMinutes: number = 10;
  // @State formNotes: string = '';

  // 新增：从编辑页面返回时接收数据
  onPageShow() {
    const params = router.getParams() as RouterParams;
    if (params && params.action === 'save' && params.event) {
      const newEvent = JSON.parse(params.event) as CalendarEvent;
      this.addOrUpdateEvent(newEvent);
      // 清除参数，避免重复添加
      router.replaceUrl({ url: 'pages/Index' });
    }
  }


  // 新增：添加或更新事件
  private addOrUpdateEvent(event: CalendarEvent) {
    if (event.id && event.id > 0) {
      // 更新现有事件
      this.events = this.events.map(e => e.id === event.id ? event : e);
    } else {
      // 添加新事件 - 手动创建新对象
      const newEvent: CalendarEvent = {
        id: this.nextEventId++,
        title: event.title,
        dateKey: event.dateKey,
        startTime: event.startTime,
        endTime: event.endTime,
        reminderMinutes: event.reminderMinutes,
        notes: event.notes,
        _timerId: undefined
      };

      // 修复：使用 concat 方法而不是展开运算符
      this.events = this.events.concat([newEvent]);
      this.scheduleReminder(newEvent);
    }
  }

  // 修改：获取本周日期范围
  private getWeekDates(centerDate: Date): Date[] {
    const start = new Date(centerDate);
    const dayOfWeek = start.getDay();
    start.setDate(start.getDate() - dayOfWeek);

    const weekDates: Date[] = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(start);
      date.setDate(start.getDate() + i);
      weekDates.push(date);
    }
    return weekDates;
  }
  //
  // 新增：获取本周是第几周
  private getWeekNumber(date: Date): number {
    const firstDayOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date.getTime() - firstDayOfYear.getTime()) / 86400000;
    return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7);
  }

  // 修改：周视图标题格式
  private weekTitle(): string {
    const weekNumber = this.getWeekNumber(this.selectedDate);
    const year = this.selectedDate.getFullYear();
    const month = this.selectedDate.getMonth() + 1;
    return `${year}年${month}月第${weekNumber}周`;
  }


  private isSameDay(a: Date, b: Date): boolean {
    return a.getFullYear() === b.getFullYear() &&
      a.getMonth() === b.getMonth() &&
      a.getDate() === b.getDate();
  }

  private scheduleReminder(evt: CalendarEvent) {
    if (evt.reminderMinutes === undefined || evt.reminderMinutes === null) {
      return;
    }
    const timeParts = evt.startTime.split(':');
    const sh = Number(timeParts[0]);
    const sm = Number(timeParts[1]);
    const eventStart = new Date(evt.dateKey + 'T00:00:00');
    eventStart.setHours(sh, sm, 0, 0);
    const triggerAt = new Date(eventStart.getTime() - evt.reminderMinutes * 60 * 1000);
    const delayMs = triggerAt.getTime() - Date.now();
    if (delayMs <= 0) {
      return;
    }
    const timerHandle: number = setTimeout(() => {
      promptAction.showToast({ message: `日程提醒：${evt.title}`, duration: 2000 });
    }, delayMs) as number;
    evt._timerId = timerHandle;
  }

  private cancelReminder(evt: CalendarEvent) {
    if (evt._timerId !== undefined) {
      const timerHandle: number = evt._timerId as number;
      clearTimeout(timerHandle);
      evt._timerId = undefined;
    }
  }

  // 跳转到新建事件页面
  private navigateToNewEvent(date: Date) {
    router.pushUrl({
      url: 'pages/EditPage',
      params: {
        mode: 'create',
        date: date.getTime()
      }
    });
  }

  // 跳转到编辑事件页面
  private navigateToEditEvent(evt: CalendarEvent) {
    router.pushUrl({
      url: 'pages/EditPage',
      params: {
        mode: 'edit',
        event: JSON.stringify(evt)
      }
    });
  }

  // private openEditorForNew(date: Date) {
  //   this.editingEventId = undefined;
  //   this.formTitle = '';
  //   this.formDate = new Date(date);
  //   this.formStartMinutes = 9 * 60;
  //   this.formEndMinutes = 10 * 60;
  //   this.formReminderMinutes = 10;
  //   this.formNotes = '';
  //   this.showEditor = true;
  // }
  //
  // private openEditorForEdit(evt: CalendarEvent) {
  //   this.editingEventId = evt.id;
  //   this.formTitle = evt.title;
  //   // parse dateKey
  //   const dateParts = evt.dateKey.split('-');
  //   const y = Number(dateParts[0]);
  //   const m = Number(dateParts[1]);
  //   const d = Number(dateParts[2]);
  //   this.formDate = new Date(y, m - 1, d);
  //   this.formStartMinutes = parseTimeToMinutes(evt.startTime);
  //   this.formEndMinutes = parseTimeToMinutes(evt.endTime);
  //   this.formReminderMinutes = evt.reminderMinutes ?? 0;
  //   this.formNotes = evt.notes ?? '';
  //   this.showEditor = true;
  // }
  //
  // private saveEditor() {
  //   const dateKey = formatDateKey(this.formDate);
  //   const startTime = minutesToTime(this.formStartMinutes);
  //   const endTime = minutesToTime(this.formEndMinutes);
  //   if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
  //     promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
  //     return;
  //   }
  //   if (this.editingEventId === undefined) {
  //     const newEvt: CalendarEvent = {
  //       id: this.nextEventId++,
  //       title: this.formTitle,
  //       dateKey,
  //       startTime,
  //       endTime,
  //       reminderMinutes: this.formReminderMinutes,
  //       notes: this.formNotes
  //     };
  //     const newEvents: CalendarEvent[] = [];
  //     for (let i = 0; i < this.events.length; i++) {
  //       newEvents.push(this.events[i]);
  //     }
  //     newEvents.push(newEvt);
  //     this.events = newEvents;
  //     this.scheduleReminder(newEvt);
  //     this.selectedDate = new Date(this.formDate);
  //     this.monthViewDate = new Date(this.formDate);
  //   } else {
  //     this.events = this.events.map(e => {
  //       if (e.id === this.editingEventId) {
  //         this.cancelReminder(e);
  //         const updated: CalendarEvent = {
  //           id: e.id,
  //           title: this.formTitle,
  //           dateKey: dateKey,
  //           startTime: startTime,
  //           endTime: endTime,
  //           reminderMinutes: this.formReminderMinutes,
  //           notes: this.formNotes,
  //           _timerId: undefined
  //         };
  //         // reschedule
  //         this.scheduleReminder(updated);
  //         return updated;
  //       }
  //       return e;
  //     });
  //   }
  //   this.showEditor = false;
  // }
  //
  private deleteEvent(evt: CalendarEvent) {
    this.cancelReminder(evt);
    this.events = this.events.filter(e => e.id !== evt.id);
    promptAction.showToast({ message: '已删除', duration: 1200 });
  }

  private eventsOn(date: Date): CalendarEvent[] {
    const k = formatDateKey(date);
    return this.events.filter(e => e.dateKey === k)
      .sort((a, b) => parseTimeToMinutes(a.startTime) - parseTimeToMinutes(b.startTime));
  }

  private weekDatesAround(d: Date): Date[] {
    const start = new Date(d);
    const w = d.getDay();
    start.setDate(d.getDate() - w);
    const arr: Date[] = [];
    for (let i = 0; i < 7; i++) {
      const x = new Date(start);
      x.setDate(start.getDate() + i);
      arr.push(x);
    }
    return arr;
  }

  private monthTitle(): string {
    const y = this.monthViewDate.getFullYear();
    const m = this.monthViewDate.getMonth() + 1;
    return `${y}年${m}月`;
  }

  private selectedDateHeading(): string {
    const d = this.selectedDate;
    return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')} 日程`;
  }

  private selectedDateFull(): string {
    const d = this.selectedDate;
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`;
  }

  // private createTimePickerDate(totalMinutes: number): Date {
  //   const base = new Date(this.formDate);
  //   const hour = Math.floor(totalMinutes / 60);
  //   const minute = totalMinutes % 60;
  //   const result = new Date(base);
  //   result.setHours(hour, minute, 0, 0);
  //   return result;
  // }

  private getPreviewEvents(date: Date): CalendarEvent[] {
    const events = this.eventsOn(date);
    const preview: CalendarEvent[] = [];
    for (let i = 0; i < events.length && i < 2; i++) {
      preview.push(events[i]);
    }
    return preview;
  }

  // 新增：获取所有日程（按日期排序）
  private getAllEvents(): CalendarEvent[] {
    return this.events.sort((a, b) => {
      const dateCompare = a.dateKey.localeCompare(b.dateKey);
      if (dateCompare !== 0) return dateCompare;
      return parseTimeToMinutes(a.startTime) - parseTimeToMinutes(b.startTime);
    });
  }

  // 新增：计算属性用于周视图
  private get weekDates(): Date[] {
    return this.getWeekDates(this.selectedDate);
  }

  private get weekNumber(): number {
    return this.getWeekNumber(this.selectedDate);
  }

  @Builder
  renderExtraIndicator(totalCount: number) {
    if (totalCount > 2) {
      Text(`+${totalCount - 2} 更多`).fontSize(10).opacity(0.7);
    }
  }

  // @Builder
  // renderSelectedDayEventsList(events: CalendarEvent[]) {
  //   if (events.length === 0) {
  //     Text('暂无日程').opacity(0.6).padding(12);
  //     // return;
  //   }
  //   else {
  //     ForEach(events, (evt: CalendarEvent) => {
  //       Row() {
  //         Column() {
  //           Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
  //           Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
  //         }.alignItems(HorizontalAlign.Start).layoutWeight(1);
  //         Button('编辑').onClick(() => this.openEditorForEdit(evt)).margin({ right: 6 });
  //         Button('删除').type(ButtonType.Circle).onClick(() => this.deleteEvent(evt));
  //       }
  //       .padding(10)
  //       .margin({ left: 12, right: 12, bottom: 8 })
  //       .backgroundColor('#f7f7f7')
  //       .borderRadius(8);
  //     }, (evt: CalendarEvent) => evt.id.toString());
  //   }
  // }

  //新的
  @Builder
  renderSelectedDayEventsList(events: CalendarEvent[]) {
    if (events.length === 0) {
      Text('暂无日程').opacity(0.6).padding(12);
    } else {
      ForEach(events, (evt: CalendarEvent) => {
        Row() {
          Column() {
            Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
            Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);
          Button('编辑').onClick(() => this.navigateToEditEvent(evt)).margin({ right: 6 });
          Button('删除').type(ButtonType.Circle).onClick(() => this.deleteEvent(evt));
        }
        .padding(10)
        .margin({ left: 12, right: 12, bottom: 8 })
        .backgroundColor('#f7f7f7')
        .borderRadius(8);
      }, (evt: CalendarEvent) => evt.id.toString());
    }
  }

  // @Builder
  // renderDayViewEvents(events: CalendarEvent[]) {
  //   if (events.length === 0) {
  //     Text('今天暂无安排').opacity(0.6).padding(12);
  //   } else {
  //     ForEach(events, (evt: CalendarEvent) => {
  //       Column() {
  //         Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
  //         Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
  //
  //         // 直接在 @Builder 中判断
  //         if (evt.notes && evt.notes.length > 0) {
  //           Text(evt.notes).fontSize(12).opacity(0.9).margin({ top: 4 });
  //         }
  //
  //         Row() {
  //           Button('编辑').onClick(() => this.openEditorForEdit(evt)).margin({ right: 8 });
  //           Button('删除').type(ButtonType.Circle).onClick(() => this.deleteEvent(evt));
  //         }.margin({ top: 6 });
  //       }
  //       .padding(12)
  //       .margin({ left: 12, right: 12, bottom: 10 })
  //       .backgroundColor('#f7f7f7')
  //       .borderRadius(8);
  //     }, (evt: CalendarEvent) => evt.id.toString());
  //   }
  // }

  //新的
  @Builder
  renderDayViewEvents(events: CalendarEvent[]) {
    if (events.length === 0) {
      Text('今天暂无安排').opacity(0.6).padding(12);
    } else {
      ForEach(events, (evt: CalendarEvent) => {
        Column() {
          Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
          Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
          if (evt.notes && evt.notes.length > 0) {
            Text(evt.notes).fontSize(12).opacity(0.9).margin({ top: 4 });
          }
          Row() {
            Button('编辑').onClick(() => this.navigateToEditEvent(evt)).margin({ right: 8 });
            Button('删除').type(ButtonType.Circle).onClick(() => this.deleteEvent(evt));
          }.margin({ top: 6 });
        }
        .padding(12)
        .margin({ left: 12, right: 12, bottom: 10 })
        .backgroundColor('#f7f7f7')
        .borderRadius(8);
      }, (evt: CalendarEvent) => evt.id.toString());
    }
  }

  // @Builder
  // renderEventNote(evt: CalendarEvent) {
  //   if (evt.notes && evt.notes.length > 0) {
  //     Text(evt.notes).fontSize(12).opacity(0.9).margin({ top: 4 });
  //   }
  // }
  //
  // @Builder
  // renderEditorOverlay() {
  //   if (this.showEditor) {
  //     // return;
  //     Stack() {
  //       // Dialog content
  //         Column() {
  //           Text(this.editingEventId === undefined ? '新建日程' : '编辑日程')
  //             .fontSize(18).fontWeight(FontWeight.Bold).padding({ bottom: 8 });
  //
  //           // Title
  //           Text('标题').fontSize(14).opacity(0.8).alignSelf(ItemAlign.Start);
  //           TextInput({ placeholder: '请输入标题', text: this.formTitle })
  //             .onChange(v => this.formTitle = v)
  //             .height(36)
  //             .backgroundColor('#f5f5f5')
  //             .borderRadius(6)
  //             .padding({ left: 8, right: 8 })
  //             .margin({ bottom: 8 });
  //
  //           // Date
  //           Text('日期').fontSize(14).opacity(0.8).alignSelf(ItemAlign.Start);
  //           DatePicker({
  //             start: new Date(2000, 0, 1),
  //             end: new Date(2100, 11, 31),
  //             selected: this.formDate
  //           })
  //             .onChange((value: DatePickerResult) => {
  //               this.formDate = new Date(value.year, value.month - 1, value.day);
  //             })
  //             .margin({ bottom: 8 });
  //
  //           // Time range
  //           Text('开始时间').fontSize(14).opacity(0.8).alignSelf(ItemAlign.Start);
  //           TimePicker({
  //             selected: this.createTimePickerDate(this.formStartMinutes)
  //           })
  //             .useMilitaryTime(true)
  //             .onChange((value: TimePickerResult) => {
  //               this.formStartMinutes = value.hour * 60 + value.minute;
  //             })
  //             .margin({ bottom: 6 });
  //
  //           Text('结束时间').fontSize(14).opacity(0.8).alignSelf(ItemAlign.Start);
  //           TimePicker({
  //             selected: this.createTimePickerDate(this.formEndMinutes)
  //           })
  //             .useMilitaryTime(true)
  //             .onChange((value: TimePickerResult) => {
  //               this.formEndMinutes = value.hour * 60 + value.minute;
  //             })
  //             .margin({ bottom: 6 });
  //
  //           // Reminder
  //           Text('提前提醒（分钟）').fontSize(14).opacity(0.8).alignSelf(ItemAlign.Start);
  //           Slider({
  //             min: 0,
  //             max: 120,
  //             value: this.formReminderMinutes,
  //             step: 5
  //           })
  //             .showSteps(true)
  //             .onChange((v: number) => this.formReminderMinutes = Math.round(v));
  //           Text(`${this.formReminderMinutes} 分钟`).fontSize(12).opacity(0.7).margin({ bottom: 6 });
  //
  //           // Notes
  //           Text('备注').fontSize(14).opacity(0.8).alignSelf(ItemAlign.Start);
  //           TextInput({ placeholder: '可选', text: this.formNotes })
  //             .onChange(v => this.formNotes = v)
  //             .height(36)
  //             .backgroundColor('#f5f5f5')
  //             .borderRadius(6)
  //             .padding({ left: 8, right: 8 })
  //             .margin({ bottom: 10 });
  //
  //           Row() {
  //             Button('取消')
  //               .type(ButtonType.Normal)
  //               .onClick(() => this.showEditor = false)
  //               .margin({ right: 12 });
  //             Button('保存')
  //               .type(ButtonType.Capsule)
  //               .backgroundColor('#1677ff')
  //               .fontColor(Color.White)
  //               .onClick(() => this.saveEditor());
  //           }.justifyContent(FlexAlign.End).width('100%').margin({ top: 8 });
  //         }
  //         .width('92%')
  //         .padding(16)
  //         .backgroundColor(Color.White)
  //         .borderRadius(12)
  //         .shadow({ radius: 20, color: '#00000020', offsetX: 0, offsetY: 6 });
  //     }
  //     .width('100%')
  //     .height('100%')
  //     .backgroundColor('#00000033')
  //     .align(Alignment.Center)
  //     .onClick(() => {
  //       // click backdrop to close
  //       this.showEditor = false;
  //     });
  //   }
  //   // Semi-transparent backdrop
  //
  // }

  // 新增：所有日程列表
  @Builder
  renderAllEventsList() {
    if (this.events.length === 0) {
      Column() {
        Text('暂无日程')
          .fontSize(16)
          .opacity(0.6)
          .margin({ top: 50 });
        Text('点击右下角"+"按钮创建第一个日程')
          .fontSize(12)
          .opacity(0.4)
          .margin({ top: 8 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    } else {
      Scroll() {
        Column() {
          ForEach(this.getAllEvents(), (evt: CalendarEvent) => {
            Column() {
              Row() {
                Column() {
                  Text(evt.dateKey)
                    .fontSize(12)
                    .opacity(0.6);
                  Text(evt.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium);
                  Text(`${evt.startTime} - ${evt.endTime}`)
                    .fontSize(12)
                    .opacity(0.8);
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Row() {
                  Button('编辑')
                    .onClick(() => this.navigateToEditEvent(evt))
                    .margin({ right: 6 });
                  Button('删除')
                    .type(ButtonType.Circle)
                    .onClick(() => this.deleteEvent(evt));
                }
              }

              if (evt.notes && evt.notes.length > 0) {
                Text(evt.notes)
                  .fontSize(12)
                  .opacity(0.9)
                  .margin({ top: 4 })
                  .alignSelf(ItemAlign.Start);
              }
            }
            .padding(12)
            .margin({ left: 12, right: 12, bottom: 8 })
            .backgroundColor('#f7f7f7')
            .borderRadius(8);
          }, (evt: CalendarEvent) => evt.id.toString());
        }
      }
    }
  }

  // 修改：周视图构建器 - 将逻辑拆分成多个小构建器
  @Builder
  renderWeekHeader(weekDates: Date[]) {
    Row() {
      ForEach(['日', '一', '二', '三', '四', '五', '六'], (wd: string, index: number) => {
        Column() {
          Text(wd)
            .fontSize(14)
            .opacity(0.7)
            .margin({ bottom: 4 });
          Text(`${weekDates[index].getMonth() + 1}/${weekDates[index].getDate()}`)
            .fontSize(12)
            .opacity(0.8);
        }
        .width('14.28%')
        .padding(4)
        .backgroundColor(this.isSameDay(weekDates[index], this.selectedDate) ? '#f0f5ff' : Color.Transparent)
        .borderRadius(6)
        .onClick(() => {
          this.selectedDate = new Date(weekDates[index]);
        });
      }, (wd: string, index?: number) => wd + index)
    }
    .width('100%')
    .padding({ left: 8, right: 8, bottom: 12 })
  }

  @Builder
  renderWeekDay(date: Date) {
    Column() {
      // 日期标题
      Text(`${date.getDate()}`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 });

      // 该日期的事件
      Scroll() {
        Column() {
          ForEach(this.eventsOn(date), (evt: CalendarEvent) => {
            Column() {
              Text(evt.title)
                .fontSize(12)
                .maxLines(1);
              Text(`${evt.startTime}-${evt.endTime}`)
                .fontSize(10)
                .opacity(0.7);
            }
            .padding(4)
            .backgroundColor('#e6f7ff')
            .borderRadius(4)
            .margin({ bottom: 4 })
            .onClick(() => this.navigateToEditEvent(evt));
          }, (evt: CalendarEvent) => evt.id.toString());

          // 如果没有事件，显示提示
          if (this.eventsOn(date).length === 0) {
            Text('无日程')
              .fontSize(10)
              .opacity(0.5)
              .margin({ top: 20 });
          }
        }
      }
      .height(120)
    }
    .width('14.28%')
    .padding(6)
    .backgroundColor(this.isSameDay(date, this.selectedDate) ? '#f0f8ff' : '#f9f9f9')
    .borderRadius(8)
  }

  @Builder
  renderWeekView() {
    // 在构建器外部获取数据，然后传入构建器
    Column() {
      // 渲染周表头
      this.renderWeekHeader(this.getWeekDates(this.selectedDate));

      // 渲染周内容
      Row() {
        ForEach(this.getWeekDates(this.selectedDate), (date: Date, index?: number) => {
          this.renderWeekDay(date);
        }, (date: Date, index?: number) => formatDateKey(date) + index)
      }
      .width('100%')
      .height(200)
    }
    .width('100%')
    .padding(12)
    .justifyContent(FlexAlign.Start)
    .height(400)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // Header with navigation and date
      Column() {
        // App Title and navigation
        Row() {
          Button('<')
            .type(ButtonType.Circle)
            .backgroundColor('#ffe9b22e')
            .onClick(() => {
              if (this.currentTabIndex === 0) {
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
            })
          Blank()
          Text('日历')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          Blank()
          Button('>')
            .type(ButtonType.Circle)
            .backgroundColor('#ffe9b22e')
            .onClick(() => {
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
            })
        }
        .width('100%')
        .padding(12)

        // Text(this.monthTitle())
        //   .fontSize(18)
        //   .fontWeight(FontWeight.Bold)
        //   .padding({ left: 16, right: 16, bottom: 8 })

        // 修改：根据当前标签显示不同标题
        if (this.currentTabIndex === 0) {
          Text(this.monthTitle())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .padding({ left: 16, right: 16, bottom: 8 });
        } else if (this.currentTabIndex === 1) {
          Text(this.weekTitle())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .padding({ left: 16, right: 16, bottom: 8 });
        }

        Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
          TabContent() {
            // Month View
            Column() {
              // Weekday header
              Row() {
                ForEach(['日', '一', '二', '三', '四', '五', '六'], (wd: string) => {
                  Text(wd).width('14.28%').textAlign(TextAlign.Center).fontSize(14).opacity(0.7)
                }, (wd: string) => wd)
              }
              .width('100%')
              .padding({ left: 8, right: 8, bottom: 6 })

              // Grid 6x7
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(getMonthGridDates(this.monthViewDate), (d: Date) => {
                  Column() {
                    Text(d.getDate().toString())
                      .fontSize(16)
                      .fontWeight(this.isSameDay(d, this.selectedDate) ? FontWeight.Bold : FontWeight.Normal)
                      .textAlign(TextAlign.Center)
                      .margin({ top: 6 })
                      .opacity(d.getMonth() === this.monthViewDate.getMonth() ? 1 : 0.5)
                      .backgroundColor(this.isSameDay(d, this.today) ? '#e6f4ff' : Color.Transparent)
                      .borderRadius(6);
                    ForEach(this.getPreviewEvents(d), (e: CalendarEvent) => {
                      Row() {
                        Text('•').fontColor('#1890ff');
                        Text(e.title).fontSize(12).lineHeight(14).maxLines(1);
                      }.margin({ top: 2 }).padding({ left: 4, right: 4 });
                    }, (e: CalendarEvent) => e.id.toString());
                    this.renderExtraIndicator(this.eventsOn(d).length);
                  }
                  .width('14.28%')
                  .height(64)
                  .padding({ left: 4, right: 4 })
                  .onClick(() => {
                    this.selectedDate = new Date(d);
                  });
                }, (d: Date) => formatDateKey(d));
              }
              .width('100%')
              .padding({ left: 6, right: 6, bottom: 8 })

              // Selected day events list
              Column() {
                Text(this.selectedDateHeading())
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: 12, top: 8, bottom: 6 });
                this.renderSelectedDayEventsList(this.eventsOn(this.selectedDate));
              }
            }
          }.tabBar('月')

          TabContent() {
            // Week View
            this.renderWeekView();
          }.tabBar('周')

          TabContent() {
            // Day View
            Column() {
              Text(this.selectedDateFull()).fontSize(18).fontWeight(FontWeight.Medium).padding(12);
              this.renderDayViewEvents(this.eventsOn(this.selectedDate));
            }
          }.tabBar('日')

          // 新增：所有日程标签页
          TabContent() {
            Column() {
              Text('所有日程')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .padding(12);
              this.renderAllEventsList();
            }
          }.tabBar('所有日程')
        }
        .onChange((i: number) => this.currentTabIndex = i)
        .barMode(BarMode.Fixed)
        .width('100%')
        .height('65%')
      }
      .width('100%')
      .height('100%')

      // Floating Add Button
      Button('+')
        .type(ButtonType.Capsule)
        .backgroundColor('#ffe9b22e')
        .fontColor(Color.White)
        .position({ x: '300.00vp', y: '680.00vp' })
        // .translate({ x: -20, y: -20 })
        // .onClick(() => this.openEditorForNew(this.selectedDate))
        //新的
        .onClick(() => this.navigateToNewEvent(this.selectedDate))

      // Editor Overlay
      // this.renderEditorOverlay();
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
  }
}