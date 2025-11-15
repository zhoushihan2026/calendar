import { CalendarEvent} from '../utils/CalendarTypes';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface EventsData {
  list: CalendarEvent[];
}

@Component
export struct MyContent {
  @Link currentTabIndex: number;
  @Link selectedDate: Date;
  @Link monthViewDate: Date;
  // @Link events: CalendarEvent[];
  @Link eventsData: EventsData;

  aboutToAppear() {
    console.log('=== MyContent 事件详情 ===');
    console.log('事件数量:', this.eventsData.list.length);

    this.eventsData.list.forEach((event, index) => {
      console.log(`事件${index}: ID=${event.id}, 标题=${event.title}, 日期=${event.dateKey}`);
    });
  }

  private dayTitle(): string {
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
  private getTitleText(): string {
    switch (this.currentTabIndex) {
      case 0: return this.monthTitle();
      case 1: return this.weekTitle();
      case 2: return this.dayTitle();
      case 3: return '所有日程';
      default: return '';
    }
  }
  // 比较两个日期是否是同一天
  private isSameDay(a: Date, b: Date): boolean {
    return a.getFullYear() === b.getFullYear() &&
      a.getMonth() === b.getMonth() &&
      a.getDate() === b.getDate();
  }
  // 将Date对象格式化为"YYYY-MM-DD"字符串
  private formatDateKey(d: Date): string {
    const y = d.getFullYear();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${day}`;
  }
  // 将"HH:MM"时间字符串转换为分钟数
  private parseTimeToMinutes(time: string): number {
    const parts = time.split(':');
    const h = parseInt(parts[0]);
    const m = parseInt(parts[1]);
    return h * 60 + m;
  }
  // 获取指定日期的所有事件并按开始时间排序
  private eventsOn(date: Date): CalendarEvent[] {
    const k = this.formatDateKey(date);
    return this.eventsData.list.filter(e => e.dateKey === k)
      .sort((a, b) => this.parseTimeToMinutes(a.startTime) - this.parseTimeToMinutes(b.startTime));
  }
  // 月视图日期单元格中显示事件预览
  private getPreviewEvents(date: Date): CalendarEvent[] {
    const events = this.eventsOn(date);
    return events.length > 0 ? [events[0]] : [];  // 只返回第一个事件或空数组
  }
  // 所有日程视图的完整列表
  private getAllEvents(): CalendarEvent[] {
    return this.eventsData.list.sort((a, b) => {
      const dateCompare = a.dateKey.localeCompare(b.dateKey);
      if (dateCompare !== 0) return dateCompare;
      return this.parseTimeToMinutes(a.startTime) - this.parseTimeToMinutes(b.startTime);
    });
  }
  // 生成完整的月历网格
  private getMonthGridDates(viewDate: Date): Date[] {
  const firstOfMonth = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1);
  const startDay = firstOfMonth.getDay();
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
  // 生成一周的日期范围
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
  // 明确标识选中日期的日程区域
  private selectedDateHeading(): string {
    const d = this.selectedDate;
    return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')} 日程`;
  }
  // 提供事件编辑入口
  private navigateToEditEvent(evt: CalendarEvent) {
    router.pushUrl({
      url: 'pages/EditPage',
      params: {
        mode: 'edit',
        event: JSON.stringify(evt)
      }
    });
  }
  // 提供事件删除功能（带确认弹框）
  private deleteEvent(evt: CalendarEvent) {
    promptAction.showDialog({
      title: '确认删除',
      message: `确定要删除日程"${evt.title}"吗？`,
      buttons: [
        { text: '取消', color: '#000000' },
        { text: '删除', color: '#FF0000' }
      ]
    }).then(result => {
      if (result.index === 1) {
        // 实际删除逻辑 - 通知父组件
        const updatedList = this.eventsData.list.filter(e => e.id !== evt.id);
        this.eventsData = { list: updatedList };

        // 取消提醒定时器
        if (evt._timerId) {
          clearTimeout(evt._timerId);
        }

        promptAction.showToast({ message: '已删除日程', duration: 1500 });
        console.log('删除事件成功:', evt.title);
      }
    });
  }

  // 在月视图底部显示选中日期的详细事件列表
  @Builder
  renderSelectedDayEventsList(events: CalendarEvent[]) {
    if (events.length === 0) {
      Text('暂无日程').opacity(0.6).padding(12);
    } else {
      ForEach(events, (evt: CalendarEvent) => {
        Column() {
          Row() {
            Column() {
              Text(evt.dateKey).fontSize(12).opacity(0.6);
              Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
              Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
            }.alignItems(HorizontalAlign.Start).layoutWeight(1);
          }
          if (evt.notes && evt.notes.length > 0) {
            Text(evt.notes).fontSize(12).opacity(0.9).margin({ top: 4 }).alignSelf(ItemAlign.Start);
          }
        }
        .padding(12)
        .margin({ left: 12, right: 12, bottom: 8 })
        .backgroundColor('#f7f7f7')
        .borderRadius(8)
        .onClick(() => {
          this.navigateToEditEvent(evt);
        });
      }, (evt: CalendarEvent) => evt.id.toString());
    }
  }
  // 在月视图的日期单元格中，有事件时显示小圆点
  // @Builder
  // renderExtraIndicator(totalCount: number) {
  //   if (totalCount > 0) {
  //     // 有事件时显示小圆点
  //     Text('•')
  //       .fontSize(16)
  //       .fontColor('#1890ff')
  //       .margin({ top: 2 });
  //   }
  // }
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
              .backgroundColor(this.isSameDay(d, new Date()) ? '#fffffde6' : Color.Transparent)
              .borderRadius(15)
              .width(30)
              .height(30)
            ForEach(this.getPreviewEvents(d), (e: CalendarEvent) => {
              Row() {
                Text('•').fontColor('#ffffe818');
                // Text(e.title).fontSize(12).lineHeight(14).maxLines(1);
              }.margin({ top: 2 }).padding({ left: 4, right: 4 });
            }, (e: CalendarEvent) => e.id.toString());
            // this.renderExtraIndicator(this.eventsOn(d).length);
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
    Column() {
      // 周视图表头
      Row() {
        ForEach(['日', '一', '二', '三', '四', '五', '六'], (wd: string, index: number) => {
          Column() {
            Text(wd).fontSize(14).opacity(0.7).margin({ bottom: 4 });
            Text(`${this.getWeekDates(this.selectedDate)[index].getMonth() + 1}/${this.getWeekDates(this.selectedDate)[index].getDate()}`).fontSize(12).opacity(0.8);
          }
          .width('14.28%')
          .padding(4)
          .backgroundColor(this.isSameDay(this.getWeekDates(this.selectedDate)[index], this.selectedDate) ? '#fffffde6' : Color.Transparent)
          .borderRadius(6)
          .onClick(() => {
            this.selectedDate = new Date(this.getWeekDates(this.selectedDate)[index]);
          });
        }, (wd: string, index?: number) => wd + index)
      }
      .width('100%')
      .padding({ left: 8, right: 8, bottom: 12 })

      // 周视图内容
      Row() {
        ForEach(this.getWeekDates(this.selectedDate), (date: Date, index?: number) => {
          Column() {
            Text(`${date.getDate()}`).fontSize(16).fontWeight(FontWeight.Medium).margin({ bottom: 8 });
            Scroll() {
              Column() {
                ForEach(this.eventsOn(date), (evt: CalendarEvent) => {
                  Column() {
                    Text(evt.title).fontSize(12).maxLines(1).fontWeight(FontWeight.Medium);
                    Text(`${evt.startTime}-${evt.endTime}`).fontSize(10).opacity(0.7);
                  }
                  .padding(6)
                  .backgroundColor('#fffffccb')
                  .borderRadius(4)
                  .margin({ bottom: 4 })
                  .width('100%')
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
          .backgroundColor(this.isSameDay(date, this.selectedDate) ? '#fffffde6' : '#f9f9f9')
          .borderRadius(8)
        }, (date: Date, index?: number) => this.formatDateKey(date) + index)
      }
      .width('100%')
      .height(200)
    }
    .width('100%')
    .padding(12)
  }
  @Builder
  renderDayView() {
    Column() {
      // 日视图的事件列表
      if (this.eventsOn(this.selectedDate).length === 0) {
        Text('今天暂无安排').opacity(0.6).padding(12);
      } else {
        ForEach(this.eventsOn(this.selectedDate), (evt: CalendarEvent) => {
          Column() {
            Row() {
              Column() {
                Text(evt.dateKey).fontSize(12).opacity(0.6);
                Text(evt.title).fontSize(16).fontWeight(FontWeight.Medium);
                Text(`${evt.startTime} - ${evt.endTime}`).fontSize(12).opacity(0.8);
              }.alignItems(HorizontalAlign.Start).layoutWeight(1);
              Row() {
                Button('编辑').onClick(() => this.navigateToEditEvent(evt)).margin({ right: 6 }).backgroundColor("#ffeccc2f");
                Button('删除').onClick(() => this.deleteEvent(evt)).backgroundColor("#FF6B6B");
              }.margin({top:15})
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
  @Builder
  renderAllEventsList() {
    if (this.eventsData.list.length === 0) {
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
                  Button('编辑').onClick(() => this.navigateToEditEvent(evt)).margin({ right: 6 }).backgroundColor("#ffeccc2f");
                  Button('删除').onClick(() => this.deleteEvent(evt)).backgroundColor("#FF6B6B");
                }.margin({top:15})
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

  build() {
    Column() {
      // 根据当前标签显示不同标题
      Text(this.getTitleText())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding({ left: 16, right: 16, bottom: 8 });

      Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
        TabContent() {
          this.renderMonthView();
        }.tabBar('月')

        TabContent() {
          this.renderWeekView();
        }.tabBar('周')

        TabContent() {
            this.renderDayView();
        }.tabBar('日')

        TabContent() {
            this.renderAllEventsList();
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