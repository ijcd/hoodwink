require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink::DataStore do

  describe "brand new, empty datastore" do
    let(:ds) { Hoodwink::DataStore.new }

    before(:each) { ds.clear! }

    it "should return an empty list on #find_all" do
      assert { ds.find_all(:fish2).empty? }
    end

    it "should raise RecordNotFound on #find" do
      expect {
        ds.find(:fish, 1)
      }.should raise_error(Hoodwink::RecordNotFound)
    end

    it "should allow you to #create a record with id" do
      ds.create(:fowl, "id" => 2)
      assert { ds.find(:fowl, 2) }
    end

    it "should allow you to #create a record without an id" do
      record = ds.create(:fowl)
      assert { ds.find(:fowl, record.id) }
    end
  end

  # TODO: add tests for other methods on datastore
  describe "with some models in it" do
    let(:ds) { Hoodwink::DataStore.new }

    before(:each) do
      ds.clear!
      ds.create(:fish, :color => "red")
      @fish_blue = ds.create(:fish, :color => "blue")
      ds.create(:fish, :color => "green")
      ds.create(:fowl, :size => "small")
      ds.create(:fowl, :size => "medium")
      ds.create(:fowl, :size => "large")
      ds.create(:fowl, :size => "gigantic")
      ds.create(:beast, :id => 1, :color => "brown")
    end

    describe "#find_all" do
      it "should return all records" do
        assert { ds.find_all(:fish).length == 3 }
        assert { ds.find_all(:fowl).length == 4 }
        assert { ds.find_all(:beast).length == 1 }
      end
    end

    describe "#find" do
      it "should find by id" do
        assert { ds.find(:fish, @fish_blue.id).color == "blue" }
      end
    end
  end

end

