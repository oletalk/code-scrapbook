export type FilterState = {
  search: string,
  fromDate: string,
  toDate: string,
}

export type FilterProps = {
  filter: FilterState,
  onChange: (fs : FilterState) => void,
}

export enum DocColName {
  RCVD = 'date_rcvd',
  DOC_TYPE = 'doc_type',
  SENDER = 'sender'
}
export enum ViewMode {
  NORMAL = 'normal',
  CALENDAR = 'calendar'
}
export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc'
}

export type SortColumnProps = {
  name: string,
  sorting: SortOrder | undefined,
  onToggle: (name: string, fs : SortOrder | undefined) => void,
}
export interface SenderComponentProps<T> {
  sender_id: string,
  info: T,
  onChange: (ac : T) => void,
  refreshCallback: Function
}

