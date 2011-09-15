require File.expand_path('../../spec_helper', __FILE__)

describe "Pod::Source" do
  extend SpecHelper::Git
  extend SpecHelper::TemporaryDirectory

  before do
    add_repo('repo1', fixture('spec-repos/master'))
    (config.repos_dir + 'repo1/JSONKit').rmtree
    add_repo('repo2', fixture('spec-repos/master'))
    (config.repos_dir + 'repo2/Reachability').rmtree
  end

  it "returns a specification set by name from any spec repo" do
    set = Pod::Source.search(Pod::Dependency.new('Reachability'))
    set.should.be.instance_of Pod::Specification::Set
    set.pod_dir.should == config.repos_dir + 'repo1/Reachability'

    set = Pod::Source.search(Pod::Dependency.new('JSONKit'))
    set.should.be.instance_of Pod::Specification::Set
    set.pod_dir.should == config.repos_dir + 'repo2/JSONKit'
  end
end
