export interface CalendarEvent {
  id: number,
  title: string,
  dateKey: string,
  startTime: string,
  endTime: string,
  reminderMinutes?: number,
  notes?: string,
  reminderId?: number //系统提醒ID，用于取消提醒
}

export interface EventsData {
  list: CalendarEvent[];
}

export const DEFAULT_EVENTS_DATA: EventsData = {
  list: [
    { id: 1, title: '示例日程', dateKey: '2025-11-16', startTime: '10:35', endTime: '11:00', reminderMinutes: 5, notes: '这是一个示例', reminderId: undefined },
    { id: 2, title: '团队会议', dateKey: '2025-12-20', startTime: '14:00', endTime: '15:30', reminderMinutes: 10, notes: '每周团队同步会议', reminderId: undefined },
    { id: 3, title: '健身房锻炼', dateKey: '2025-12-20', startTime: '18:00', endTime: '19:30', reminderMinutes: 30, notes: '胸肌训练', reminderId: undefined },
    { id: 4, title: '项目评审', dateKey: '2025-11-19', startTime: '09:00', endTime: '11:00', reminderMinutes: 15, notes: '与客户进行项目进度评审', reminderId: undefined },
    { id: 5, title: '午餐约会', dateKey: '2025-11-23', startTime: '12:00', endTime: '13:30', reminderMinutes: 5, notes: '与朋友在市中心餐厅', reminderId: undefined },
  ]
};

export interface RouterParams {
  action?: 'save' | 'delete';
  event?: string;
}

export interface EditorParams {
  mode: 'create' | 'edit';
  date?: number;
  event?: string;
}

