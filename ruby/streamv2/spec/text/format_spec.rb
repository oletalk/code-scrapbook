require_relative '../../common/text/format'

describe Format do
  context "given an empty list" do
    songlist = []
    it "returns nothing" do
      expect(Format.html_list(songlist)).to eq("")
    end
  end

  context "given a list of two" do
    songlist = [{hash:'blah', title:'a song'},{hash:'asdf', title:'some tune'}]

    expected_r = " <a href='/play/blah/downsampled'>a song</a> <br/>\n" \
               + " <a href='/play/asdf/downsampled'>some tune</a> "

    it "returns the expected html list with downsampled songs" do
      expect(Format.html_list(songlist, downsampled=true)).to eq(expected_r)
    end
  end

  context "given a list of three" do
    songlist = [{hash:'rfcv', title:'Artist - Some Tune'}, \
                {hash:'ewfv', title:'Canción'}, \
                {hash:'4hu5', title:'(â, î or ô)_2'} ]

    expected_r = "[{\"title\":\"Artist - Some Tune\",\"hash\":\"rfcv\"}," \
               + "{\"title\":\"Canción\",\"hash\":\"ewfv\"}," \
               + "{\"title\":\"(â, î or ô)_2\",\"hash\":\"4hu5\"}]"

    it "returns the expected json list" do
      expect(Format.json_list(songlist)).to eq(expected_r)
    end
  end

  context "given a list of two" do
    songlist = [{hash:'blah', title:'a song', secs: 30},{hash:'asdf', title:'some tune', secs:120}]
    hdr_host = 'http://192.168.0.4:8888'
    expected_r = "#EXTM3U\n" \
       + "#EXTINF:30,a song\n" \
       + "http://http://192.168.0.4:8888/play/blah\n" \
       + "#EXTINF:120,some tune\n" \
       + "http://http://192.168.0.4:8888/play/asdf"

    it "returns the expected play list" do
      expect(Format.play_list(songlist, hdr_host)).to eq(expected_r)
    end
  end

end
