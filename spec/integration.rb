require File.dirname(__FILE__) + '/spec_helper'

config_file = File.dirname(__FILE__) + '/test-config.yml'

if File.exist?(config_file)
  unless defined? EWS_CONFIG
    EWS_CONFIG = YAML.load_file config_file
  end
  
  EWS::Service.endpoint EWS_CONFIG['endpoint']
  EWS::Service.set_auth EWS_CONFIG['username'], EWS_CONFIG['password']
else
  unless defined? EWS_CONFIG
    EWS_CONFIG = nil
  end
  
  puts <<-EOS

=================================================================
Create 'spec/test-config.yml' to automatically configure
the endpoint and credentials. The file is ignored via
.gitignore so it will not be committed.

endpoint:
  :uri: 'https://localhost/ews/exchange.asmx'
  :version: 1
username: testuser
password: xxxxxx

=================================================================

EOS
end

EWS::Service.logger = $stdout

describe 'Integration Tests' do
  context 'find_folder' do
    it "should find the folder without errors" do
      lambda do
        EWS::Service.find_folder(:inbox)
      end.should_not raise_error
    end

    it "should raise a Fault when the item does not exist" do
      error_msg = /The value 'does-not-exist' is invalid according to its datatype/
      lambda do
        EWS::Service.find_folder('does-not-exist')
      end.should raise_error(Handsoap::Fault,  error_msg)
    end
  end

  context 'get_folder' do
    it "should get the folder without errors" do
      EWS::Service.get_folder(:inbox).should be_instance_of(EWS::Folder)
    end
    
    it "should raise a SoapError when the ResponseMessage is an Error" do
      error_msg = /The value 'does-not-exist' is invalid according to its datatype/
      lambda do
        EWS::Service.get_folder('does-not-exist')
      end.should raise_error(Handsoap::Fault,  error_msg)
    end
  end

  context 'find_item' do
    it "should find the item without errors" do
      lambda do
        EWS::Service.find_item :inbox, :base_shape => :AllProperties
      end.should_not raise_error
    end

    it "should raise a Fault when the item does not exist" do
      error_msg = /The value 'does-not-exist' is invalid according to its datatype/
      lambda do
        EWS::Service.find_item('does-not-exist')
      end.should raise_error(Handsoap::Fault,  error_msg)
    end
  end
  
  context 'get_item' do
    it "should get the item without errors" do
      lambda do
        EWS::Service.get_item EWS_CONFIG['item_id'], :base_shape => :AllProperties
      end.should_not raise_error
    end

    it "should raise a SoapError when the ResponseMessage is an Error" do
      lambda do
        EWS::Service.get_item(nil)
      end.should raise_error(EWS::ResponseError, /Id must be non-empty/)
    end
  end

  context 'get_attachment' do
    it "should get the attachment without errors" do
      lambda do
        rtn = EWS::Service.get_attachment EWS_CONFIG['attachment_id'] # lame
      end.should_not raise_error
    end

    it "should raise a SoapError when the ResponseMessage is an Error" do
      lambda do
        EWS::Service.get_attachment(nil)
      end.should raise_error(EWS::ResponseError, /Id must be non-empty/)
    end
  end

end
