require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink::Request do

  describe "#path_to_segments" do
    def assert_segments(input, output)
      assert { Hoodwink::Request.path_to_segments(input) == output }
    end

    it "should work for an empty path" do
      assert_segments "", []
    end

    it "should work for the root path" do 
      assert_segments "/", []
    end

    it "should work for a simple path" do 
      assert_segments "/foo", ["foo"]
    end

    it "should work for a longer paths" do 
      assert_segments "/foo/bar/baz", ["foo", "bar", "baz"]
    end

    it "should work for a simple segments" do 
      assert_segments "/:bar", [":bar"]
    end

    it "should work for a longer segments" do 
      assert_segments "/foo/:bar/baz/:blip/bang", ["foo", ":bar", "baz", ":blip", "bang"]
    end
  end

  describe "#segments_to_re" do
    def assert_segments_to_re(input, output)
      assert { Hoodwink::Request.segments_to_re(input) == %r{#{output}} }
    end
    
    it "should work for an empty path" do
      assert_segments_to_re [], "/"
    end

    it "should work for a simple path" do
      assert_segments_to_re ["foo"], "/foo"
    end

    it "should work for a long path" do
      assert_segments_to_re ["foo", "bar", "baz"], "/foo/bar/baz"
    end

    it "should work for a simple segment" do
      assert_segments_to_re [":foo"], "/(?<foo>[^/]+)"
    end

    it "should work for a long segment" do
      assert_segments_to_re ["foo", ":bar", "baz", ":blip", "bang"], "/foo/(?<bar>[^/]+)/baz/(?<blip>[^/]+)/bang"
    end
  end

  describe "#path_to_segments_re" do
    def assert_matches(input, url)
      assert { Hoodwink::Request.path_to_segments_re(input).match(url) }
    end

    it "should produce a match for an empty path" do
      assert_matches "/", "/"
    end

    it "should produce a match for an simple path" do
      assert_matches "/foo", "/foo"
    end

    it "should produce a match for an longer path" do
      assert_matches "/foo/bar/baz", "/foo/bar/baz"
    end

    it "should produce a match for an simple segmented path" do
      assert_matches "/:foo", "/foo"
      assert_matches "/:foo", "/bar"
      assert_matches "/:foo", "/baz"
    end

    it "should produce a match for an longer segmented path" do
      assert_matches "/foo/:bar/baz/:bing", "/foo/b/baz/d"
    end

    it "should NOT produce a match for an longer segmented path" do
      assert { !Hoodwink::Request.path_to_segments_re("/foo/:bar/baz/:bing").match("/a/b/c/d") }
    end
  end

  describe "#extract_segment_params" do
    def extract_params(url_with_segments, url_to_match)
      resource_path_re = Hoodwink::Request.path_to_segments_re(url_with_segments)
      params = Hoodwink::Request.extract_segment_params(url_to_match, resource_path_re)
    end

    it "should return no matches for an non-matching url" do
      assert { extract_params("/foo/bar/baz/bang", "/one/two/three/four").empty? }
    end

    it "should return no matches for an non-segmented url" do
      assert { extract_params("/foo/bar/baz/bang", "/foo/bar/baz/bang").empty? }
    end

    it "should matches for an segmented url" do
      params = extract_params("/foo/:bar/baz/:bang", "/foo/one/baz/two")
      assert { params[:bar]  == "one" }
      assert { params[:bang] == "two" }
    end
  end
end
