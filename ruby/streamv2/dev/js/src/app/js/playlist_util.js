const MAX_ITEM_LENGTH = 50; // TODO - different file

function songFromJson (si, json) {
  let songitem = json;
  let item = {
     counter: si,
     hash: songitem['hash'],
     title: fixTitle(songitem['title']),
     date_added: nonnull(songitem['date_added']),
     plays: nonnull(songitem['plays']),
     last_played: nonnull(songitem['last_played']),
     derived: nonnull(songitem['title_derived'])
   };
   return item;
}

function fixTitle (title) {
  let ret = title;
   if (ret == null) {
    ret = '???';
   }
   if (ret.length > MAX_ITEM_LENGTH) {
      ret = ret.substr(0,MAX_ITEM_LENGTH - 3) + "...";
    }
    return ret;
}

function nonnull(str) {
    return (str !== undefined && str !== null) ? str : undefined;
}


export { songFromJson };
