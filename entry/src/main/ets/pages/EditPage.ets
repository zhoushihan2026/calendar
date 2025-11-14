import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EditHeader } from '../components/EditHeader';
import { TitleInput } from '../components/TitleInput';
import { DatePickerSection } from '../components/DatePickerSection';
import { TimePickerSection } from '../components/TimePickerSection';
import { ReminderSection } from '../components/ReminderSection';
import { NotesInput } from '../components/NotesInput';
import { CalendarEvent, DatePickerResult, TimePickerResult ,EditorParams} from '../components/CalendarTypes';

@Entry
@Component
export struct EditPage {
  @State formTitle: string = '';
  @State formDate: Date = new Date();
  @State formStartMinutes: number = 9 * 60;
  @State formEndMinutes: number = 10 * 60;
  @State formReminderMinutes: number = 10;
  @State formNotes: string = '';
  @State isSaving: boolean = false; // 新增：防止重复保存

  private editingEvent?: CalendarEvent;
  private isNewEvent: boolean = true;
  // private nextEventId: number = 1; // 需要从主页面同步或使用全局状态

  aboutToAppear() {
    const params = router.getParams() as EditorParams;

    if (params.mode === 'create') {
      this.isNewEvent = true;
      if (params.date) {
        this.formDate = new Date(params.date);
      }
    } else if (params.mode === 'edit' && params.event) {
      this.isNewEvent = false;
      this.editingEvent = JSON.parse(params.event) as CalendarEvent;
      this.loadEventData(this.editingEvent);
    }
  }

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

  private parseTimeToMinutes(time: string): number {
    const parts = time.split(':');
    const h = parseInt(parts[0]);
    const m = parseInt(parts[1]);
    return h * 60 + m;
  }

  private minutesToTime(minutes: number): string {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
  }

  private formatDateKey(d: Date): string {
    const y = d.getFullYear();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  private createTimePickerDate(totalMinutes: number): Date {
    const base = new Date(this.formDate);
    const hour = Math.floor(totalMinutes / 60);
    const minute = totalMinutes % 60;
    const result = new Date(base);
    result.setHours(hour, minute, 0, 0);
    return result;
  }

  // private saveEvent() {
  //   const dateKey = this.formatDateKey(this.formDate);
  //   const startTime = this.minutesToTime(this.formStartMinutes);
  //   const endTime = this.minutesToTime(this.formEndMinutes);
  //
  //   if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
  //     promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
  //     return;
  //   }
  //
  //   // 这里需要实现保存逻辑，可以通过router.back()传递数据
  //   // 或者使用全局状态管理
  //
  //   promptAction.showToast({
  //     message: this.isNewEvent ? '创建成功' : '更新成功',
  //     duration: 1500
  //   });
  //
  //   router.back();
  // }

  //新的
  private saveEvent() {
    const dateKey = this.formatDateKey(this.formDate);
    const startTime = this.minutesToTime(this.formStartMinutes);
    const endTime = this.minutesToTime(this.formEndMinutes);

    if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
      promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
      return;
    }

    // 创建事件对象
    const eventData: CalendarEvent = {
      id: this.isNewEvent ? 0 : (this.editingEvent?.id || 0),
      title: this.formTitle,
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      reminderMinutes: this.formReminderMinutes,
      notes: this.formNotes
    };

    // 显示保存成功提示
    promptAction.showToast({
      message: this.isNewEvent ? '创建成功' : '更新成功',
      duration: 1500
    });

    // 返回数据到主页面
      router.back({
        url: 'pages/Index',
        params: {
          action: 'save',
          event: JSON.stringify(eventData)
        }
      });
  }

  private cancel() {
    router.back();
  }

  build() {
    Column() {
      // EditHeader 组件
      EditHeader({
        isNewEvent: this.isNewEvent,
        formTitle: $formTitle,
        formDate: $formDate,
        formStartMinutes: $formStartMinutes,
        formEndMinutes: $formEndMinutes,
        formReminderMinutes: $formReminderMinutes,
        formNotes: $formNotes
      })
        // .onCancel(() => this.cancel())
        // .onSave(() => this.saveEvent())

      // 表单内容
      Scroll() {
        Column() {
          TitleInput({
            formTitle: $formTitle
          })

          DatePickerSection({
            formDate: $formDate
          })

          TimePickerSection({
            formStartMinutes: $formStartMinutes,
            formEndMinutes: $formEndMinutes,
            formDate: this.formDate
          })

          ReminderSection({
            formReminderMinutes: $formReminderMinutes
          })

          NotesInput({
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