require File.join( File.dirname(__FILE__), '..', 'spec_helper.rb' )

describe Magenta::DataType do

  before(:all) do
    @data_type = Magenta::DataType.new("integer", "i", "int")
  end

  it "should be frozen after initialization" do
    @data_type.name.should  == "integer"
    @data_type.should be_frozen
  end

  it "should have correctly initialized fields" do
    @data_type.name.should  == "integer"
    @data_type.prefix.should  == "i"
    @data_type.c_type.should  == "int"
    @data_type.converters.should  == {}
  end
  
  it "should return native type name in correct format" do
    @data_type.to_native_type.should  == "integer_data_type_t"
  end
  
  after(:all) do
    @data_type = nil
  end

end

