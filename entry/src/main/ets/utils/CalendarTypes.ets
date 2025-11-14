export interface CalendarEvent {
  id: number,
  title: string,
  dateKey: string,
  startTime: string,
  endTime: string,
  reminderMinutes?: number,
  notes?: string,
  _timerId?: number //标识当前日历事件关联的定时器
}

export interface DatePickerResult {
  year: number;
  month: number;
  day: number;
}

export interface TimePickerResult {
  hour: number;
  minute: number;
  second?: number;
}

export interface RouterParams {
  action?: string;
  event?: string;
}

export interface EditorParams {
  mode: 'create' | 'edit';
  date?: number;
  event?: string;
}

