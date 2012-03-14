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

    describe "#inspect" do
      it "should report an empty database" do
        assert { Hoodwink.datastore.inspect == "" }
      end
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

    describe "#inspect" do
      it "should show a full database" do
        text = Hoodwink.datastore.inspect
        assert { text[/Hoodwink::Models::Fish \(3\):/] }
        assert { text[/Hoodwink::Models::Fish:.*"color"=>"red"/] }
        assert { text[/Hoodwink::Models::Fish:.*"color"=>"blue"/] }
        assert { text[/Hoodwink::Models::Fish:.*"color"=>"green"/] }
        assert { text[/Hoodwink::Models::Fowl \(4\):/] }
        assert { text[/Hoodwink::Models::Fowl:.*"size"=>"small"/] }
        assert { text[/Hoodwink::Models::Fowl:.*"size"=>"medium"/] }
        assert { text[/Hoodwink::Models::Fowl:.*"size"=>"large"/] }
        assert { text[/Hoodwink::Models::Fowl:.*"size"=>"gigantic"/] }
        assert { text[/Hoodwink::Models::Beast \(1\):/] }
        assert { text[/Hoodwink::Models::Beast:.*"color"=>"brown"/] }
        assert { text[/Hoodwink::Models::Beast:.*"id"=>1/] }
      end
    end
  end

end

