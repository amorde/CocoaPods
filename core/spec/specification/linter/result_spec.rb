require File.expand_path('../../../spec_helper', __FILE__)
module Pod
  describe Specification::Linter::Results::Result do
    before do
      @result =
          Specification::Linter::Results::Result.new(:error,
                                                     'This is an error')
    end

    it 'returns the type' do
      @result.type.should == :error
    end

    it 'returns the message' do
      @result.message.should == 'This is an error'
    end

    it 'can store the platforms that generated the result' do
      @result.platforms << :ios
      @result.platforms.should == [:ios]
    end

    it 'returns a string representation suitable for UI' do
      @result.to_s.should == '[ERROR] This is an error'
      @result.platforms << :ios
      @result.to_s.should == '[ERROR] This is an error [iOS]'
    end
  end

  describe Specification::Linter::Results do
    before do
      @results = Specification::Linter::Results.new
    end

    it 'creates an error result' do
      @results.error('This is an error')
      @results.results.count.should == 1
      @results.results.first.type.should == :error
    end

    it 'creates a warning result' do
      @results.warning('This is a warning')
      @results.results.count.should == 1
      @results.results.first.type.should == :warning
    end

    it 'prevents duplicate results' do
      @results.warning('I have duplicate warnings')
      @results.warning('I have duplicate warnings')
      @results.results.count.should == 1
    end

    it 'specifies the platform on the result when there is a consumer' do
      fixture_path = 'spec-repos/test_repo/Specs/BananaLib/1.0/BananaLib.podspec'
      podspec_path = fixture(fixture_path)
      linter = Specification::Linter.new(podspec_path)
      @results.consumer = Specification::Consumer.new(linter.spec, :ios)
      @results.warning('bad')
      @results.results.first.platforms.first.should == :ios
    end

    it 'specifies no platform when there is no consumer' do
      @results.consumer = nil
      @results.warning('bad')
      @results.results.first.platforms.should == []
    end
  end
end
