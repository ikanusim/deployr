require File.dirname(__FILE__) + '/spec_helper' 

describe "Push" do
  include Rack::Test::Methods


  def app
    @app ||= Sinatra::Application
  end

  describe "process_all" do

    # TODO FIX ME + enhance and improve specs

    xit "should do nothing when there is a process running" do
      push = mock(Push)
      Push.any_instance.stub(:processing?).and_return(true).
      push.should_not_receive(:update_attribute)
      Push.process_all
    end

    xit "should start processing if no process is already running" do
      push = mock(Push)
      Push.any_instance.stub(:processing?).and_return(false).
      push.should_receive(:update_attribute)
      Push.process_all
    end

	end
end
