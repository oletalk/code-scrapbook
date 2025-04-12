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
  /** the sender id in the database */
  sender_id: string,
  /** the object e.g. AccountInfo or ContactInfo */
  info: T,
  /** a callback function containing the changed object info */
  onChange: (ac : T) => void,
  /** a callback function for the parent to call after an update (TODO: confirm) */
  refreshCallback: Function
}

