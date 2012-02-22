require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink::DataStore do
  context "brand new, empty datastore" do
    subject { Hoodwink::DataStore.new }

    it "should return an empty list on #find" do
      assert { subject.find_all(:fish).empty? }
    end
  end

  context "with some models in it" do
    subject { DataStore.new }
  end
end

