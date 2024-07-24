export type FilterState = {
  search: string,
  fromDate: string,
  toDate: string,
}

export type FilterProps = {
  filter: FilterState,
  onChange: (fs : FilterState) => void,
}

export interface SenderComponentProps<T> {
  sender_id: string,
  info: T,
  onChange: (ac : T) => void,
  refreshCallback: Function
}

