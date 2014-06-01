# encoding: UTF-8
require 'spec_helper'

include Feature::Repository

describe Feature::Repository::SimpleRepository do
  before(:each) do
    @repository = SimpleRepository.new
  end

  it "should have no active features after initialization" do
    @repository.active_features.should == []
  end

  it "should add an active feature" do
    @repository.add_active_feature :feature_a
    @repository.active_features.should == [:feature_a]
  end

  it "should raise an exception when adding not a symbol as active feature" do
    lambda do
      @repository.add_active_feature 'feature_a'
    end.should raise_error(ArgumentError, "given feature feature_a is not a symbol")
  end

  it "should raise an exception when adding a active feature already added as active" do
    @repository.add_active_feature :feature_a
    lambda do
      @repository.add_active_feature :feature_a
    end.should raise_error(ArgumentError, "feature :feature_a already added to list of active features")
  end
end
