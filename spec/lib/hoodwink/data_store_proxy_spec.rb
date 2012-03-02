require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink::DataStoreProxy do
  subject { Hoodwink::DataStoreProxy.new(resource_name, datastore, request) }

  let(:resource_name) { "resource_name"   }
  let(:request)       { double("request") }
  let(:datastore)     { double("datastore", :find_all => [result, result, result], :find => result) }
  let(:result)        { {} }

  describe "#find_all" do
    it "should call datastore.find_all with the current resource_name" do
      datastore.should_receive(:find_all).with(resource_name)
      subject.find_all
    end

    it "should call filter_by to filter the results" do
      datastore.should_receive(:find_all).with(resource_name)
      subject.should_receive(:filter_by).with(result).exactly(3)
      subject.find_all
    end
  end

  describe "#find" do
    it "should call datastore.find with the current resource_name" do
      datastore.should_receive(:find).with(resource_name, result)
      subject.find(result)
    end

    it "should call filter_by to filter the results" do
      datastore.should_receive(:find).with(resource_name, 5).and_return(result)
      subject.should_receive(:filter_by).with(result).exactly(1)
      subject.find(5)
    end
  end

end

