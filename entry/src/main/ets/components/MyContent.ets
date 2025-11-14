import { CalendarEvent, DatePickerResult, TimePickerResult } from '../components/CalendarTypes';

@Component
export struct MyContent {
  // @State currentTabIndex: number = 0;
  // @State selectedDate: Date = new Date();
  // @State monthViewDate: Date = new Date();
  // @State events: CalendarEvent[] = [];
  //
  // private monthTitle: string = '';
  // private weekTitle: string = '';
  // private onTabChange: (index: number) => void = () => {};
  //
  // // 构建器方法
  // @Builder renderMonthView: () => void = () => {};
  // @Builder renderWeekView: () => void = () => {};
  // @Builder renderDayView: () => void = () => {};
  // @Builder renderAllEventsList: () => void = () => {};

  // 使用 @Link 实现双向绑定
  @Link currentTabIndex: number;
  @Link selectedDate: Date;
  @Link monthViewDate: Date;
  @Prop events: CalendarEvent[];
  // @Prop monthTitle: string;
  // @Prop weekTitle: string;

  // 工具方法 - 复制自 Index
  private isSameDay(a: Date, b: Date): boolean {
    return a.getFullYear() === b.getFullYear() &&
      a.getMonth() === b.getMonth() &&
      a.getDate() === b.getDate();
  }

  private eventsOn(date: Date): CalendarEvent[] {
    const k = this.formatDateKey(date);
    return this.events.filter(e => e.dateKey === k)
      .sort((a, b) => this.parseTimeToMinutes(a.startTime) - this.parseTimeToMinutes(b.startTime));
  }

  private getPreviewEvents(date: Date): CalendarEvent[] {
    const events = this.eventsOn(date);
    const preview: CalendarEvent[] = [];
    for (let i = 0; i < events.length && i < 2; i++) {
      preview.push(events[i]);
    }
    return preview;
  }

  private getAllEvents(): CalendarEvent[] {
    return this.events.sort((a, b) => {
      const dateCompare = a.dateKey.localeCompare(b.dateKey);
      if (dateCompare !== 0) return dateCompare;
      return this.parseTimeToMinutes(a.startTime) - this.parseTimeToMinutes(b.startTime);
    });
  }

  private formatDateKey(d: Date): string {
    const y = d.getFullYear();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  private parseTimeToMinutes(time: string): number {
    const parts = time.split(':');
    const h = parseInt(parts[0]);
    const m = parseInt(parts[1]);
    return h * 60 + m;
  }

  private  getMonthGridDates(viewDate: Date): Date[] {
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

  // 新增：计算属性
  private get weekDates(): Date[] {
    return this.getWeekDates(this.selectedDate);
  }

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

  private selectedDateHeading(): string {
    const d = this.selectedDate;
    return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')} 日程`;
  }

  private selectedDateFull(): string {
    const d = this.selectedDate;
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`;
  }

  private monthTitle(): string {
    const y = this.monthViewDate.getFullYear();
    const m = this.monthViewDate.getMonth() + 1;
    return `${y}年${m}月`;
  }

  private weekTitle(): string {
    const weekNumber = this.getWeekNumber(this.selectedDate);
    const year = this.selectedDate.getFullYear();
    const month = this.selectedDate.getMonth() + 1;
    return `${year}年${month}月第${weekNumber}周`;
  }

  private getWeekNumber(date: Date): number {
    const firstDayOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date.getTime() - firstDayOfYear.getTime()) / 86400000;
    return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7);
  }

  // 事件处理方法 - 需要从 Index 传递或者使用全局状态管理
  private navigateToEditEvent(evt: CalendarEvent) {
    // 这里需要实现跳转逻辑，可以使用全局事件或回调
    console.log('编辑事件:', evt);
  }

  private deleteEvent(evt: CalendarEvent) {
    // 这里需要实现删除逻辑，可以使用全局事件或回调
    console.log('删除事件:', evt);
  }

  // 构建器方法 - 全部在 MyContent 内部实现
  @Builder
  renderExtraIndicator(totalCount: number) {
    if (totalCount > 2) {
      Text(`+${totalCount - 2} 更多`).fontSize(10).opacity(0.7);
    }
  }

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
          Button('删除').onClick(() => this.deleteEvent(evt));
        }
        .padding(10)
        .margin({ left: 12, right: 12, bottom: 8 })
        .backgroundColor('#f7f7f7')
        .borderRadius(8);
      }, (evt: CalendarEvent) => evt.id.toString());
    }
  }

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
            Button('删除').onClick(() => this.deleteEvent(evt));
          }.margin({ top: 6 });
        }
        .padding(12)
        .margin({ left: 12, right: 12, bottom: 10 })
        .backgroundColor('#f7f7f7')
        .borderRadius(8);
      }, (evt: CalendarEvent) => evt.id.toString());
    }
  }

  @Builder
  renderAllEventsList() {
    if (this.events.length === 0) {
      Column() {
        Text('暂无日程').fontSize(16).opacity(0.6).margin({ top: 50 });
        Text('点击右下角"+"按钮创建第一个日程').fontSize(12).opacity(0.4).margin({ top: 8 });
      }.width('100%').alignItems(HorizontalAlign.Center);
    } else {
      Scroll() {
        Column() {
          ForEach(this.getAllEvents(), (evt: CalendarEvent) => {
            Column() {
              Row() {
                Column() {
                  Text(evt.dateKey).fontSize(12).opacity(0.6);
                  Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
                  Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
                }.alignItems(HorizontalAlign.Start).layoutWeight(1);
                Row() {
                  Button('编辑').onClick(() => this.navigateToEditEvent(evt)).margin({ right: 6 });
                  Button('删除').onClick(() => this.deleteEvent(evt));
                }
              }
              if (evt.notes && evt.notes.length > 0) {
                Text(evt.notes).fontSize(12).opacity(0.9).margin({ top: 4 }).alignSelf(ItemAlign.Start);
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

  @Builder
  renderMonthView() {
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
        ForEach(this.getMonthGridDates(this.monthViewDate), (d: Date) => {
          Column() {
            Text(d.getDate().toString())
              .fontSize(16)
              .fontWeight(this.isSameDay(d, this.selectedDate) ? FontWeight.Bold : FontWeight.Normal)
              .textAlign(TextAlign.Center)
              .margin({ top: 6 })
              .opacity(d.getMonth() === this.monthViewDate.getMonth() ? 1 : 0.5)
              .backgroundColor(this.isSameDay(d, new Date()) ? '#e6f4ff' : Color.Transparent)
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
        }, (d: Date) => this.formatDateKey(d));
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
  }

  @Builder
  renderWeekView() {
    // 使用计算属性而不是方法调用
    Column() {
      // 周视图表头
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (wd: string, index: number) => {
          Column() {
            Text(wd).fontSize(14).opacity(0.7).margin({ bottom: 4 });
            Text(`${this.weekDates[index].getMonth() + 1}/${this.weekDates[index].getDate()}`).fontSize(12).opacity(0.8);
          }
          .width('14.28%')
          .padding(4)
          .backgroundColor(this.isSameDay(this.weekDates[index], this.selectedDate) ? '#f0f5ff' : Color.Transparent)
          .borderRadius(6)
          .onClick(() => {
            this.selectedDate = new Date(this.weekDates[index]);
          });
        }, (wd: string, index?: number) => wd + index)
      }
      .width('100%')
      .padding({ left: 8, right: 8, bottom: 12 })

      // 周视图内容
      Row() {
        ForEach(this.weekDates, (date: Date, index?: number) => {
          Column() {
            Text(`${date.getDate()}`).fontSize(16).fontWeight(FontWeight.Medium).margin({ bottom: 8 });
            Scroll() {
              Column() {
                ForEach(this.eventsOn(date), (evt: CalendarEvent) => {
                  Column() {
                    Text(evt.title).fontSize(12).maxLines(1);
                    Text(`${evt.startTime}-${evt.endTime}`).fontSize(10).opacity(0.7);
                  }
                  .padding(4)
                  .backgroundColor('#e6f7ff')
                  .borderRadius(4)
                  .margin({ bottom: 4 })
                  .onClick(() => this.navigateToEditEvent(evt));
                }, (evt: CalendarEvent) => evt.id.toString());
                if (this.eventsOn(date).length === 0) {
                  Text('无日程').fontSize(10).opacity(0.5).margin({ top: 20 });
                }
              }
            }.height(120)
          }
          .width('14.28%')
          .padding(6)
          .backgroundColor(this.isSameDay(date, this.selectedDate) ? '#f0f8ff' : '#f9f9f9')
          .borderRadius(8)
        }, (date: Date, index?: number) => this.formatDateKey(date) + index)
      }
      .width('100%')
      .height(200)
    }
    .width('100%')
    .padding(12)
  }

  build() {
    Column() {
      // 根据当前标签显示不同标题
      if (this.currentTabIndex === 0) {
        Text(this.monthTitle())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16, right: 16, bottom: 8 });
      }
      else if (this.currentTabIndex === 1) {
        Text(this.weekTitle())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16, right: 16, bottom: 8 });
      }

      Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
        TabContent() {
          this.renderMonthView();
        }.tabBar('月')

        TabContent() {
          this.renderWeekView();
        }.tabBar('周')

        TabContent() {
          Column() {
            Text(this.selectedDateFull())
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .padding(12);
            this.renderDayViewEvents(this.eventsOn(this.selectedDate));
          }
        }.tabBar('日')

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
      .onChange((i: number) => {
        this.currentTabIndex = i;
      })
      .barMode(BarMode.Fixed)
      .width('100%')
      .height('65%')
    }
  }
}