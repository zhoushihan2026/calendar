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

  aboutToAppear() {
    this.setupAllReminders(); // 不显示统计信息
  }
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
  // 新建或编辑日程
  private addOrUpdateEvent(event: CalendarEvent) {
    let newList: CalendarEvent[];
    let successMessage = '';

    // 修改
    if (event.id && event.id > 0) {
      newList = this.eventsData.list.map(e => e.id === event.id ? event : e);
      successMessage = '更新成功';
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
      successMessage = '创建成功';
    }

    this.eventsData = { list: newList };

    // 重新设置所有提醒
    this.setupAllReminders();

    // 统计远期事件数量并显示提示
    this.showOperationResult(successMessage);
  }
  // 统计并显示操作结果
  private showOperationResult(successMessage: string) {
    let longTermCount = 0;

    this.eventsData.list.forEach(evt => {
      const timeParts: string[] = evt.startTime.split(':');
      const sh: number = Number(timeParts[0]);
      const sm: number = Number(timeParts[1]);
      const dateParts = evt.dateKey.split('-');
      const year = Number(dateParts[0]);
      const month = Number(dateParts[1]);
      const day = Number(dateParts[2]);
      const eventStart: Date = new Date(year, month - 1, day, sh, sm, 0, 0);
      const delayMs: number = eventStart.getTime() - Date.now();

      if (delayMs > 2147483647) {
        longTermCount++;
      }
    });

    // 组合提示信息
    let message = successMessage;
    if (longTermCount > 0) {
      message += `，${longTermCount}个远期事件将在接近时提醒`;
    }

    promptAction.showToast({
      message: message,
      duration: 3000
    });
  }
  // 设置所有提醒
  private setupAllReminders() {
    // 清理旧定时器
    this.eventsData.list.forEach(evt => {
      if (evt._timerId) {
        clearTimeout(evt._timerId);
        evt._timerId = undefined;
      }
    });

    // 设置新提醒
    this.eventsData.list.forEach(evt => {
      this.scheduleReminder(evt);
    });
  }
  // 提醒器
  private scheduleReminder(evt: CalendarEvent) {
    if (evt.reminderMinutes === undefined || evt.reminderMinutes === null) {
      return;
    }

    const timeParts: string[] = evt.startTime.split(':');
    const sh: number = Number(timeParts[0]);
    const sm: number = Number(timeParts[1]);

    const dateParts = evt.dateKey.split('-');
    const year = Number(dateParts[0]);
    const month = Number(dateParts[1]);
    const day = Number(dateParts[2]);

    const eventStart: Date = new Date(year, month - 1, day, sh, sm, 0, 0);
    const triggerAt: Date = new Date(eventStart.getTime() - evt.reminderMinutes * 60 * 1000);
    const delayMs: number = triggerAt.getTime() - Date.now();

    const MAX_SAFE_DELAY = 2147483647; // 约24.8天

    if (delayMs <= 0) {
      return;
    }

    // 务实策略：只处理24天内的提醒
    if (delayMs <= MAX_SAFE_DELAY) {
      const timerHandle: number = setTimeout(() => {
        promptAction.showDialog({
          title: `${evt.title}`,
          message: `时间：${evt.startTime}-${evt.endTime}\n${evt.notes || ''}`,
          buttons: [{ text: '知道了', color: '#007DFF' }]
        });
      }, delayMs) as number;
      evt._timerId = timerHandle;
    }
  }
  // 获取新增事件id
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