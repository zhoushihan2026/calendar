import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { MyHeader } from '../components/MyHeader';
import { MyContent } from '../components/MyContent';
import { MyFooter } from '../components/MyFooter';
import { CalendarEvent, RouterParams } from '../utils/CalendarTypes';

interface EventsData {
  list: CalendarEvent[];
}
@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0; // 0: 月, 1: 周, 2: 日, 3:所有日程
  @State today: Date = new Date();
  @State selectedDate: Date = new Date();
  @State monthViewDate: Date = new Date(); // 月视图显示哪个月份
  // @State events: CalendarEvent[] = []; //存储所有日程事件数据
  // @State nextEventId: number = 1;
  // @Provide events: CalendarEvent[] = [];
  @StorageLink('eventsData') eventsData: EventsData = {
    list: [
      {
        id: 1,
        title: '示例日程',
        dateKey: '2025-11-15',
        startTime: '09:00',
        endTime: '10:00',
        reminderMinutes: 10,
        notes: '这是一个示例',
        _timerId: undefined
      }
    ]
  };
  @StorageLink('nextEventId') nextEventId: number = 2; // 从2开始

  aboutToAppear() {
    // 新增：页面显示时刷新数据
    console.log('=== Index aboutToAppear ===');
    console.log('当前 nextEventId:', this.nextEventId);
    console.log('当前事件数量:', this.eventsData.list.length);
    // this.refreshEvents();
  }
  // 从编辑页面返回时接收数据
  // onPageShow() {
  //   const params = router.getParams() as RouterParams;
  //
  //   // 重点检查：参数是否为 undefined
  //   if (params === undefined) {
  //     return; // 直接返回，避免后续错误
  //   }
  //
  //   if (params && params.action === 'save' && params.event) {
  //     try {
  //       const newEvent = JSON.parse(params.event) as CalendarEvent;
  //       // console.log('解析后的事件:', newEvent);
  //       this.addOrUpdateEvent(newEvent);
  //       // 立即清除参数
  //       router.replaceUrl({ url: 'pages/Index' });
  //     } catch (error) {
  //     }
  //   }
  // }

  onPageShow() {
    const params = router.getParams() as RouterParams;
    if (params === undefined) {
      return;
    }

    if (params && params.action === 'save' && params.event) {
      try {
        const newEvent = JSON.parse(params.event) as CalendarEvent;
        this.addOrUpdateEvent(newEvent);
        router.replaceUrl({ url: 'pages/Index' });
      }
      catch (error) {
        console.error('解析事件数据失败:', error);
      }
    }
    else if (params && params.action === 'delete' && params.event) {
      try {
        const deleteEvent = JSON.parse(params.event) as CalendarEvent;
        console.log('准备删除事件:', deleteEvent.title);
        this.deleteEvent(deleteEvent);
        router.replaceUrl({ url: 'pages/Index' });
      } catch (error) {
        console.error('解析删除事件数据失败:', error);
      }
    }
  }
  private refreshEvents() {
    // 可以从本地存储加载事件
  }
  // 新增：添加或更新事件
  // private addOrUpdateEvent(event: CalendarEvent) {
  //   if (event.id && event.id > 0) {
  //     // 更新现有事件
  //     this.events = this.events.map(e => e.id === event.id ? event : e);
  //   } else {
  //     // 添加新事件 - 手动创建新对象
  //     const newEvent: CalendarEvent = {
  //       id: this.nextEventId++,
  //       title: event.title,
  //       dateKey: event.dateKey,
  //       startTime: event.startTime,
  //       endTime: event.endTime,
  //       reminderMinutes: event.reminderMinutes,
  //       notes: event.notes,
  //       _timerId: undefined
  //     };
  //
  //     // 修复：使用 concat 方法而不是展开运算符
  //     this.events = this.events.concat([newEvent]);
  //     this.scheduleReminder(newEvent);
  //   }
  // }

  // private addOrUpdateEvent(event: CalendarEvent) {
  //   if (event.id && event.id > 0) {
  //     // 更新现有事件 - 创建新数组触发更新
  //     this.events = this.events.map(e => e.id === event.id ? event : e);
  //   } else {
  //     // 添加新事件 - 创建新数组触发更新
  //     const newEvent: CalendarEvent = {
  //       id: this.nextEventId++,
  //       title: event.title,
  //       dateKey: event.dateKey,
  //       startTime: event.startTime,
  //       endTime: event.endTime,
  //       reminderMinutes: event.reminderMinutes,
  //       notes: event.notes,
  //       _timerId: undefined
  //     };
  //
  //     // 重要：创建全新的数组，而不是修改原数组
  //     this.events = [...this.events, newEvent];
  //     // console.log('添加后事件数量:', this.events.length);
  //
  //     this.scheduleReminder(newEvent);
  //   }
  //
  //   // 额外触发：强制更新相关状态（可选）
  //   this.selectedDate = new Date(this.selectedDate);
  // }
  // private scheduleReminder(evt: CalendarEvent) {
  //   if (evt.reminderMinutes === undefined || evt.reminderMinutes === null) {
  //     return;
  //   }
  //   const timeParts = evt.startTime.split(':');
  //   const sh = Number(timeParts[0]);
  //   const sm = Number(timeParts[1]);
  //   const eventStart = new Date(evt.dateKey + 'T00:00:00');
  //   eventStart.setHours(sh, sm, 0, 0);
  //   const triggerAt = new Date(eventStart.getTime() - evt.reminderMinutes * 60 * 1000);
  //   const delayMs = triggerAt.getTime() - Date.now();
  //   if (delayMs <= 0) {
  //     return;
  //   }
  //   const timerHandle: number = setTimeout(() => {
  //     promptAction.showToast({ message: `日程提醒：${evt.title}`, duration: 2000 });
  //   }, delayMs) as number;
  //   evt._timerId = timerHandle;
  // }

  // 新增删除事件方法
  private deleteEvent(event: CalendarEvent) {
    // 从数组中移除事件
    const updatedList = this.eventsData.list.filter(e => e.id !== event.id);
    this.eventsData = { list: updatedList };

    // 取消提醒定时器
    if (event._timerId) {
      clearTimeout(event._timerId);
    }

    promptAction.showToast({ message: '删除成功', duration: 1500 });
  }

  private addOrUpdateEvent(event: CalendarEvent) {
    let newList: CalendarEvent[];

    if (event.id && event.id > 0) {
      newList = this.eventsData.list.map(e => e.id === event.id ? event : e);
    }
    else {
      const newId = this.nextEventId++;
      const newEvent: CalendarEvent = {
        id: newId,
        title: event.title,
        dateKey: event.dateKey,
        startTime: event.startTime,
        endTime: event.endTime,
        reminderMinutes: event.reminderMinutes,
        notes: event.notes,
        _timerId: undefined
      };
      newList = [...this.eventsData.list, newEvent]; // 这里应该是添加，不是覆盖
      this.scheduleReminder(newEvent);
    }

    this.eventsData = { list: newList };
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

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        MyHeader({
          currentTabIndex: this.currentTabIndex,
          selectedDate: $selectedDate,
          monthViewDate: $monthViewDate
        })

        MyContent({
          currentTabIndex: $currentTabIndex,
          selectedDate: $selectedDate,
          monthViewDate: $monthViewDate,
          eventsData: $eventsData,
        })
      }
      .width('100%')
      .height('100%')

      MyFooter({
        defaultToday: this.today
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
  }
}