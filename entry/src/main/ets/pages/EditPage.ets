import router from '@ohos.router';
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
  @State formStartMinutes: number = 0;
  @State formEndMinutes: number = 0;
  @State formReminderMinutes: number = 10;
  @State formNotes: string = '';

  // 管理编辑页面的状态和模式
  private editingEvent?: CalendarEvent;
  private isNewEvent: boolean = true;

  // 设置默认日期 加载现有事件数据
  aboutToAppear() {
    const params = router.getParams() as EditorParams;

    // 新建
    if (params.mode === 'create') {
      this.isNewEvent = true;
      if (params.date) {
        this.formDate = new Date(params.date);
      }
    }
    // 编辑
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
    const m = Number(dateParts[1]) - 1;
    const d = Number(dateParts[2]);
    this.formDate = new Date(y, m , d);
    this.formStartMinutes = this.parseTimeToMinutes(event.startTime);
    this.formEndMinutes = this.parseTimeToMinutes(event.endTime);
    this.formReminderMinutes = event.reminderMinutes ?? 10;
    this.formNotes = event.notes ?? '';
  }
  // 工具 -将 "HH:MM" 时间字符串转换为分钟数
  private parseTimeToMinutes(time: string): number {
    const parts = time.split(':');
    const h = parseInt(parts[0]);
    const m = parseInt(parts[1]);
    return h * 60 + m;
  }

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