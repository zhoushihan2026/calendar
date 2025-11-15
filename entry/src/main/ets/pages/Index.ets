import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { MyHeader } from '../components/MyHeader';
import { MyContent } from '../components/MyContent';
import { MyFooter } from '../components/MyFooter';
import { CalendarEvent, RouterParams , EventsData, DEFAULT_EVENTS_DATA} from '../utils/CalendarTypes';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0; // 0: 月, 1: 周, 2: 日, 3:所有日程
  @State today: Date = new Date();
  @State selectedDate: Date = new Date();
  @State monthViewDate: Date = new Date(); // 月视图显示哪个月份
  @StorageLink('eventsData') eventsData: EventsData = DEFAULT_EVENTS_DATA;

  onPageShow() {
    const params = router.getParams() as RouterParams;
    if (params === undefined) {
      return;
    }
    // 操作类型是 'save'，进行删除操作
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
    // 操作类型是 'delete'，进行删除操作
    else if (params && params.action === 'delete' && params.event) {
      try {
        const deleteEvent = JSON.parse(params.event) as CalendarEvent;
        this.deleteEvent(deleteEvent);
        router.replaceUrl({ url: 'pages/Index' });
      } catch (error) {
        console.error('解析删除事件数据失败:', error);
      }
    }
  }
  // 删除日程
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
  // 新建或更新日程
  private addOrUpdateEvent(event: CalendarEvent) {
    let newList: CalendarEvent[];
    // 修改
    if (event.id && event.id > 0) {
      newList = this.eventsData.list.map(e => e.id === event.id ? event : e);
    }
    // 新增
    else {
      const newId = this.getNextEventId();
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
      newList = [...this.eventsData.list, newEvent];
      this.scheduleReminder(newEvent);
    }
    // 重新渲染，显示更新后的事件
    this.eventsData = { list: newList };
  }
  // 日程提醒
  private scheduleReminder(evt: CalendarEvent) {
    if (evt.reminderMinutes === undefined || evt.reminderMinutes === null) {
      return;
    }
    // 计算从现在到提醒时间的毫秒数
    const timeParts = evt.startTime.split(':');
    const sh = Number(timeParts[0]);
    const sm = Number(timeParts[1]);
    const eventStart = new Date(evt.dateKey + 'T00:00:00');
    eventStart.setHours(sh, sm, 0, 0);
    const triggerAt = new Date(eventStart.getTime() - evt.reminderMinutes * 60 * 1000);
    const delayMs = triggerAt.getTime() - Date.now();
    // 检查提醒时间是否已经过去
    if (delayMs <= 0) {
      return;
    }
    // 设置定时器，进行提醒
    const timerHandle: number = setTimeout(() => {
      promptAction.showToast({
        message: `日程提醒：${evt.title}`,
        duration: 3000 });
    }, delayMs) as number;
    // 将定时器的标识符保存到事件对象中，方便以后取消这个定时器
    evt._timerId = timerHandle;
  }
  // 工具 - 计算新事件id
  private getNextEventId(): number {
    if (this.eventsData.list.length === 0) {
      return 1; // 如果没有事件，从1开始
    }
    // 找到当前最大的 ID，然后 +1
    const ids = this.eventsData.list.map(event => event.id);
    const maxId = Math.max(...ids);
    return maxId + 1;
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