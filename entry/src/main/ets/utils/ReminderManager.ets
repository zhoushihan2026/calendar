import reminderAgentManager from '@ohos.reminderAgentManager';
import { CalendarEvent } from './CalendarTypes';

export class ReminderManager {
  // 创建系统提醒
  static async createReminder(event: CalendarEvent): Promise<number> {
    try {
      const reminderTime = ReminderManager.calculateReminderTime(event);

      // 检查是否已过期
      if (reminderTime.getTime() <= Date.now()) {
        return -1;
      }

      // 使用类型断言
      const reminderRequest = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: reminderTime.getFullYear(),
          month: reminderTime.getMonth() + 1,
          day: reminderTime.getDate(),
          hour: reminderTime.getHours(),
          minute: reminderTime.getMinutes(),
          second: 0
        },
        title: event.title,
        content: ReminderManager.buildReminderContent(event),
        notificationId: event.id
      } as reminderAgentManager.ReminderRequestCalendar;

      const reminderId = await reminderAgentManager.publishReminder(reminderRequest);
      return reminderId;
    } catch (error) {
      return -1;
    }
  }
  // 取消系统提醒
  static async cancelReminder(reminderId: number): Promise<void> {
    if (reminderId && reminderId > 0) {
      try {
        await reminderAgentManager.cancelReminder(reminderId);
      } catch (error) {
      }
    }
  }
  // 计算提醒时间
  private static calculateReminderTime(event: CalendarEvent): Date {
    const timeParts: string[] = event.startTime.split(':');
    const sh: number = Number(timeParts[0]);
    const sm: number = Number(timeParts[1]);

    const dateParts = event.dateKey.split('-');
    const year = Number(dateParts[0]);
    const month = Number(dateParts[1]);
    const day = Number(dateParts[2]);

    const eventStart: Date = new Date(year, month - 1, day, sh, sm, 0, 0);
    const reminderTime = new Date(eventStart.getTime() - (event.reminderMinutes || 0) * 60 * 1000);

    return reminderTime;
  }
  // 构建提醒内容
  private static buildReminderContent(event: CalendarEvent): string {
    let content = `时间：${event.startTime}-${event.endTime}`;
    if (event.notes && event.notes.trim() !== '') {
      content += `\n备注：${event.notes}`;
    }
    if (event.reminderMinutes && event.reminderMinutes > 0) {
      content += `\n提前${event.reminderMinutes}分钟提醒`;
    }
    return content;
  }
}