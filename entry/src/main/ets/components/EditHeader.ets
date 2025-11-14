import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CalendarEvent } from '../utils/CalendarTypes';

@Component
export struct EditHeader {
  @Prop isNewEvent: boolean = true;
  @Link formTitle: string;
  @Link formDate: Date;
  @Link formStartMinutes: number;
  @Link formEndMinutes: number;
  @Link formReminderMinutes: number;
  @Link formNotes: string;

  private handleCancel() {
    router.back();
  }
  // private handleSave() {
  //   // 验证表单数据
  //   if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
  //     promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
  //     return;
  //   }
  //
  //   // 格式化数据
  //   const dateKey = this.formatDateKey(this.formDate);
  //   const startTime = this.minutesToTime(this.formStartMinutes);
  //   const endTime = this.minutesToTime(this.formEndMinutes);
  //
  //   // 创建事件对象
  //   const eventData: CalendarEvent = {
  //     id: this.isNewEvent ? 0 : 0, // 实际ID在Index页面处理
  //     title: this.formTitle,
  //     dateKey: dateKey,
  //     startTime: startTime,
  //     endTime: endTime,
  //     reminderMinutes: this.formReminderMinutes,
  //     notes: this.formNotes
  //   };
  //
  //   // 显示保存成功提示
  //   promptAction.showToast({
  //     message: this.isNewEvent ? '创建成功' : '更新成功',
  //     duration: 1500
  //   });
  //
  //   // 返回数据到主页面
  //   router.back({
  //     url: 'pages/Index',
  //     params: {
  //       action: 'save',
  //       event: JSON.stringify(eventData)
  //     }
  //   });
  // }
  private handleSave() {
    // 验证表单数据
    if (!this.formTitle || this.formEndMinutes <= this.formStartMinutes) {
      promptAction.showToast({ message: '请检查标题与时间范围', duration: 2000 });
      return;
    }

    // 格式化数据
    const dateKey = this.formatDateKey(this.formDate);
    const startTime = this.minutesToTime(this.formStartMinutes);
    const endTime = this.minutesToTime(this.formEndMinutes);

    // 创建事件对象
    const eventData: CalendarEvent = {
      id: this.isNewEvent ? 0 : 0, // 实际ID在Index页面处理
      title: this.formTitle,
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      reminderMinutes: this.formReminderMinutes,
      notes: this.formNotes
    };

    console.log('=== 保存事件数据 ===');
    console.log('事件标题:', eventData.title);
    console.log('事件日期:', eventData.dateKey);
    console.log('事件时间:', eventData.startTime, '-', eventData.endTime);
    console.log('完整事件对象:', eventData);

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
  // 将 Date 对象转换为 "YYYY-MM-DD" 格式
  private formatDateKey(d: Date): string {
    const y = d.getFullYear();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${y}-${m}-${day}`;
  }
  // 将分钟数转换为 "HH:MM" 格式
  private minutesToTime(minutes: number): string {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
  }

  build() {
    Row() {
      Button('←')
        .type(ButtonType.Circle)
        .onClick(() => this.handleCancel())
        .backgroundColor('#ffe9b22e');

      Text(this.isNewEvent ? '新建日程' : '编辑日程')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center);

      Button('保存')
        .onClick(() => this.handleSave())
        .fontSize(16)
        .backgroundColor('#ffe9b22e')
        .fontColor(Color.White)
        .padding({ left: 16, right: 16 });
    }
    .width('100%')
    .padding(12)
    .border({ width: { bottom: 1 }, color: '#f0f0f0' })
  }
}