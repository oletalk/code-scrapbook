export type FilterState = {
  search: string,
  fromDate: string,
  toDate: string,
}

export type FilterProps = {
  filter: FilterState,
  onChange: (fs : FilterState) => void,
}