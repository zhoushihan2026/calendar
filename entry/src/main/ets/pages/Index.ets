import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { MyHeader } from '../components/MyHeader';
import { MyContent } from '../components/MyContent';
import { MyFooter } from '../components/MyFooter';
import { CalendarEvent, RouterParams , EventsData, DEFAULT_EVENTS_DATA} from '../utils/CalendarTypes';
import { ReminderManager } from '../utils/ReminderManager';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0; // 0: 月, 1: 周, 2: 日, 3:所有日程
  @State today: Date = new Date();
  @State selectedDate: Date = new Date();
  @State monthViewDate: Date = new Date(); // 月视图显示哪个月份
  @StorageLink('eventsData') eventsData: EventsData = DEFAULT_EVENTS_DATA;

  aboutToAppear() {
    this.initializeSystemReminders(); // 初始化系统提醒
    this.triggerExpiryCheck();// 应用启动时触发过期检查
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
        // 保存后触发过期检查
        this.triggerExpiryCheck();
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
        // 删除后触发过期检查
        this.triggerExpiryCheck();
      } catch (error) {
        console.error('解析删除事件数据失败:', error);
      }
    }
  }
  // 初始化系统提醒
  private async initializeSystemReminders() {
    let hasUpdates = false;
    const updatedList: CalendarEvent[] = [];

    // 为所有需要提醒的事件创建系统提醒
    for (const event of this.eventsData.list) {
      if (event.reminderMinutes !== undefined && event.reminderMinutes !== null && !event.reminderId) {
        const reminderId = await ReminderManager.createReminder(event);
        if (reminderId > 0) {
          // 手动创建新对象并设置 reminderId
          const updatedEvent: CalendarEvent = {
            id: event.id,
            title: event.title,
            dateKey: event.dateKey,
            startTime: event.startTime,
            endTime: event.endTime,
            reminderMinutes: event.reminderMinutes,
            notes: event.notes,
            reminderId: reminderId
          };
          updatedList.push(updatedEvent);
          hasUpdates = true;
        } else {
          // 保持原事件不变
          updatedList.push(event);
        }
      } else {
        // 保持原事件不变
        updatedList.push(event);
      }
    }

    if (hasUpdates) {
      this.eventsData = { list: updatedList };
    }
  }
  // 删除日程
  private async deleteEvent(event: CalendarEvent) {
    // 取消系统提醒
    if (event.reminderId) {
      await ReminderManager.cancelReminder(event.reminderId);
    }

    // 从数组中移除事件
    const updatedList = this.eventsData.list.filter(e => e.id !== event.id);
    this.eventsData = { list: updatedList };

    // 删除后触发过期检查
    this.triggerExpiryCheck();

    promptAction.showToast({ message: '删除成功', duration: 1500 });
  }
  // 新建或编辑日程
  private async addOrUpdateEvent(event: CalendarEvent) {
    let newList: CalendarEvent[];
    let successMessage = '';

    if (event.id && event.id > 0) {
      // 修改：先取消旧的系统提醒
      const oldEvent = this.eventsData.list.find(e => e.id === event.id);
      if (oldEvent?.reminderId) {
        await ReminderManager.cancelReminder(oldEvent.reminderId);
      }

      // 创建新的系统提醒
      const reminderId = await ReminderManager.createReminder(event);

      // 手动创建更新后的事件对象
      const updatedEvent: CalendarEvent = {
        id: event.id,
        title: event.title,
        dateKey: event.dateKey,
        startTime: event.startTime,
        endTime: event.endTime,
        reminderMinutes: event.reminderMinutes,
        notes: event.notes,
        reminderId: reminderId
      };

      newList = this.eventsData.list.map(e => e.id === event.id ? updatedEvent : e);
      successMessage = '更新成功';
    } else {
      // 新增
      const newId = this.getNextEventId();
      const reminderId = await ReminderManager.createReminder(event);

      // 手动创建新事件对象
      const newEvent: CalendarEvent = {
        id: newId,
        title: event.title,
        dateKey: event.dateKey,
        startTime: event.startTime,
        endTime: event.endTime,
        reminderMinutes: event.reminderMinutes,
        notes: event.notes,
        reminderId: reminderId
      };

      // 使用数组拼接创建新数组
      newList = [];
      for (let i = 0; i < this.eventsData.list.length; i++) {
        newList.push(this.eventsData.list[i]);
      }
      newList.push(newEvent);
      successMessage = '创建成功';
    }

    this.eventsData = { list: newList };
    // 添加/更新后触发过期检查
    this.triggerExpiryCheck();
    promptAction.showToast({ message: successMessage, duration: 1500 });
  }
  private getNextEventId(): number {
    if (this.eventsData.list.length === 0) {
      return 1; // 如果没有事件，从1开始
    }
    // 找到当前最大的 ID，然后 +1
    const ids = this.eventsData.list.map(event => event.id);
    const maxId = Math.max(...ids);
    return maxId + 1;
  }
  // 触发过期检查的方法
  private triggerExpiryCheck() {
    // 通过创建新对象来触发ArkUI的响应式更新
    // 这样 MyContent 组件中的 isEventExpired 方法会被重新调用
    this.eventsData = { list: [...this.eventsData.list] };
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