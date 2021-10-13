const MAX_ITEM_LENGTH = 50 // TODO - different file

type SongObject = {
  counter: number,
  hash: string,
  title: string,
  date_added: string,
  plays: number,
  last_played: string,
  title_derived: string, /* did we invent a title for display (1), or is the file tagged in the db (0) */
  secs_display?: string
}

function songFromJson(si: number, json: SongObject): SongObject {
  const songitem = json
  const item: SongObject = {
    counter: si,
    hash: songitem.hash,
    title: fixTitle(songitem.title),
    date_added: nonnull(songitem.date_added),
    plays: nonnull(songitem.plays),
    last_played: nonnull(songitem.last_played),
    title_derived: nonnull(songitem.title_derived),
    secs_display: nonnull(songitem.secs_display)
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


export { songFromJson, SongObject }
