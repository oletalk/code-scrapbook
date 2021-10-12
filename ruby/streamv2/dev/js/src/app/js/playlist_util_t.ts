const MAX_ITEM_LENGTH = 50 // TODO - different file

type SongObject = {
  counter: number,
  hash: string,
  title: string,
  date_added: string,
  plays: number,
  last_played: string,
  derived: string,
  secs_display?: string
}
type SongFromJson = {
  counter: number,
  hash: string,
  title: string,
  date_added: string,
  plays: number,
  last_played: string,
  title_derived: string,
  secs_display?: string
}

// yeah, i know...
function SongObjectToJson(s: SongObject): SongFromJson {
  const ret: SongFromJson = {
    counter: s.counter,
    hash: s.hash,
    title: s.title,
    date_added: s.date_added,
    plays: s.plays,
    last_played: s.last_played,
    secs_display: s.secs_display,
    title_derived: s.derived
  }

  return ret
}
function songFromJson(si: number, json: SongFromJson): SongObject {
  const songitem = json
  const item: SongObject = {
    counter: si,
    hash: songitem['hash'],
    title: fixTitle(songitem['title']),
    date_added: nonnull(songitem['date_added']),
    plays: nonnull(songitem['plays']),
    last_played: nonnull(songitem['last_played']),
    derived: nonnull(songitem['title_derived']),
    secs_display: nonnull(songitem['secs_display'])
  }
  return item
}

function fixTitle(title: string) {
  let ret = title
  if (ret == null) {
    ret = '???'
  }
  if (ret.length > MAX_ITEM_LENGTH) {
    ret = ret.substr(0, MAX_ITEM_LENGTH - 3) + "..."
  }
  return ret
}

function nonnull(str: any) {
  return (str !== undefined && str !== null) ? str : undefined
}


export { songFromJson, SongObject, SongFromJson, SongObjectToJson }
