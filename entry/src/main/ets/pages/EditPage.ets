import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EditHeader } from '../components/EditHeader';
import { EditInputTitle } from '../components/EditInputTitle';
import { EditSelectDate } from '../components/EditSelectDate';
import { EditSelectTime } from '../components/EditSelectTime';
import { EditReminder } from '../components/EditReminder';
import { EditInputNotes } from '../components/EditInputNotes';
import { CalendarEvent, EditorParams} from '../utils/CalendarTypes';

@Entry
@Component
export struct EditPage {
  @State formTitle: string = '';
  @State formDate: Date = new Date();
  @State formStartMinutes: number = 9 * 60;
  @State formEndMinutes: number = 10 * 60;
  @State formReminderMinutes: number = 10;
  @State formNotes: string = '';

  // 管理编辑页面的状态和模式
  private editingEvent?: CalendarEvent;
  private isNewEvent: boolean = true;
  // private nextEventId: number = 1; // 需要从主页面同步或使用全局状态

  // 设置默认日期 加载现有事件数据
  aboutToAppear() {
    const params = router.getParams() as EditorParams;

    if (params.mode === 'create') {
      this.isNewEvent = true;
      if (params.date) {
        this.formDate = new Date(params.date);
      }
    }
    else if (params.mode === 'edit' && params.event) {
      this.isNewEvent = false;
      this.editingEvent = JSON.parse(params.event) as CalendarEvent;
      this.loadEventData(this.editingEvent);
    }
  }
  // 将编辑的事件数据加载到表单中
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
  // 将 "HH:MM" 时间字符串转换为分钟数
  private parseTimeToMinutes(time: string): number {
    const parts = time.split(':');
    const h = parseInt(parts[0]);
    const m = parseInt(parts[1]);
    return h * 60 + m;
  }
  // 为时间选择器创建合适的 Date 对象
  private createTimePickerDate(totalMinutes: number): Date {
    const base = new Date(this.formDate);
    const hour = Math.floor(totalMinutes / 60);
    const minute = totalMinutes % 60;
    const result = new Date(base);
    result.setHours(hour, minute, 0, 0);
    return result;
  }

  // // 将分钟数转换为 "HH:MM" 时间格式
  // private minutesToTime(minutes: number): string {
  //   const h = Math.floor(minutes / 60);
  //   const m = minutes % 60;
  //   return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
  // }
  // // 将日期格式化为 "YYYY-MM-DD" 字符串
  // private formatDateKey(d: Date): string {
  //   const y = d.getFullYear();
  //   const m = (d.getMonth() + 1).toString().padStart(2, '0');
  //   const day = d.getDate().toString().padStart(2, '0');
  //   return `${y}-${m}-${day}`;
  // }

  build() {
    Column() {
      EditHeader({
        isNewEvent: this.isNewEvent,
        editingEvent: this.editingEvent,
        formTitle: $formTitle,
        formDate: $formDate,
        formStartMinutes: $formStartMinutes,
        formEndMinutes: $formEndMinutes,
        formReminderMinutes: $formReminderMinutes,
        formNotes: $formNotes
      })

      Scroll() {
        Column() {
          EditInputTitle({
            formTitle: $formTitle
          })

          EditSelectDate({
            formDate: $formDate
          })

          EditSelectTime({
            formStartMinutes: $formStartMinutes,
            formEndMinutes: $formEndMinutes,
            formDate: this.formDate
          })

          EditReminder({
            formReminderMinutes: $formReminderMinutes
          })

          EditInputNotes({
            formNotes: $formNotes
          })
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