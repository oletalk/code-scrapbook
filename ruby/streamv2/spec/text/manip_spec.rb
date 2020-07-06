require_relative '../../text/manip'

describe Manip do
  context "given an empty list" do
    songlist = []
    it "returns nothing" do
      expect(Manip.shorten_titles(songlist, 10)).to eq([])
    end
  end

  context "given a short list with long titles" do
    songlist = [{'title' => 'abcdefghijkl'}, \
                {'title' => '1234567890'}, \
                {'title' => '123456789012'}]
    expected_s = [{'title' => 'abcdefg...'}, \
                  {'title' => '1234567890'}, \
                  {'title' => '1234567...'}]
    it "returns shortened titles" do
      expect(Manip.shorten_titles(songlist, 10)).to eq(expected_s)
    end
  end

end
