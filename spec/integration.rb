require File.join(File.dirname(__FILE__), 'spec_helper')

config_file = File.join(File.dirname(__FILE__), '/test-config.yml')

if File.exist?(config_file)
  unless defined? EWS_CONFIG
    EWS_CONFIG = YAML.load_file config_file
  end
  
  EWS::Service.endpoint EWS_CONFIG['endpoint'],
    :request_server_version => EWS_CONFIG['request_server_version']
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

endpoint: 'https://localhost/ews/exchange.asmx'
request_server_version: Exchange2007_SP1
username: testuser
password: xxxxxx
item_id: AABC
attachment_id: AACD
resolve_names: Peter
dump_soap: false

=================================================================

EOS
end

EWS::Service.logger = $stdout if EWS_CONFIG['dump_soap']

describe 'Integration Tests' do
  context "resolve_names" do
    it "should resolve names" do
      lambda do
        resolutions = EWS::Service.resolve_names! EWS_CONFIG['resolve_names']
        resolutions.should be_instance_of(Array)
      end.should_not raise_error
    end    
  end
  
  context 'find_folder' do
    it "should find the folder without errors" do
      lambda do
        EWS::Service.find_folder(:inbox)
      end.should_not raise_error
    end

    it "should find the public folders root folder without errors" do
      lambda do
        EWS::Service.find_folder(:publicfoldersroot)
      end.should_not raise_error
    end

    it "should raise a ResponseError when the folder does not exist" do
      lambda do
        EWS::Service.find_folder('does-not-exist')
      end.should raise_error(EWS::ResponseError, /Id is malformed/)
    end
  end

  context 'get_folder' do
    it "should get the folder using the Default base_shape" do
      EWS::Service.get_folder(:inbox).should be_instance_of(EWS::Folder)
    end

    it "should get the folder using the AllProperties base_shape" do
      folder = EWS::Service.get_folder(:inbox, :base_shape => :AllProperties)
      folder.should be_instance_of(EWS::Folder)
    end

    it "should get the folder without errors" do
      EWS::Service.get_folder(:inbox).should be_instance_of(EWS::Folder)
    end
    
    it "should raise a ResponseError when the folder does not exist" do
      lambda do
        EWS::Service.get_folder('does-not-exist')
      end.should raise_error(EWS::ResponseError, /Id is malformed/)
    end
  end

  context 'find_item' do
    it "should find the item using the base_shape of 'Default'" do
      items = EWS::Service.find_item :inbox, :base_shape => :Default
      items.should be_instance_of(Array)
    end

    it "should find the item using the base_shape of 'AllProperties'" do
      items = EWS::Service.find_item :inbox, :base_shape => :AllProperties
      items.should be_instance_of(Array)
    end

    it "should find specific items with a query string and limit" do
      items = EWS::Service.find_item :inbox, :base_shape => :Default,
        :offset => 42, :limit => 6,
        :query_string => {:participants => EWS_CONFIG['resolve_names']}
      items.should satisfy {|x| x.map(&:class) == [EWS::Message] * 6 }
    end

    it "should raise a ResponseError when the item does not exist" do
      lambda do
        EWS::Service.find_item('does-not-exist')
      end.should raise_error(EWS::ResponseError, /Id is malformed/)
    end
  end
  
  context 'get_item' do
    it "should get the item using the base_shape of 'IdOnly'" do
      item = EWS::Service.get_item EWS_CONFIG['item_id'], :base_shape => :IdOnly
      item.should be_instance_of(EWS::Message)      
    end
    
    it "should get the item using the base_shape of 'Default'" do
      item = EWS::Service.get_item EWS_CONFIG['item_id'], :base_shape => :Default
      item.should be_instance_of(EWS::Message)
    end

    it "should get the item using the base_shape of 'AllProperties'" do
      item = EWS::Service.get_item EWS_CONFIG['item_id'], :base_shape => :AllProperties
      item.should be_instance_of(EWS::Message)
    end
    
    it "should raise an error when the requested id is nil" do
      lambda do
        EWS::Service.get_item(nil)
      end.should raise_error(EWS::PreconditionFailed, /Id must be non-empty/)
    end
  end

  context 'get_attachment' do
    it "should get the attachment without errors" do
      lambda do
        rtn = EWS::Service.get_attachment EWS_CONFIG['attachment_id'] # lame
      end.should_not raise_error
    end
    
    it "should raise an error when the requested id is nil" do
      lambda do
        EWS::Service.get_attachment(nil)
      end.should raise_error(EWS::PreconditionFailed, /Id must be non-empty/)
    end
  end

  context 'move_item' do
    #it "should move the item" do
    #  folder_id =
    #  id = 
    #
    #  EWS::Service.move_item!(folder_id, [id])
    # end

    it "should raise an EWS::ResponseError when the item id does not exist" do
      lambda do
        EWS::Service.move_item!('aaaaa', ['does-not-exist'])
      end.should raise_error(EWS::ResponseError, /Id is malformed/)
    end

    it "should raise a EWS::ResponseError when the folder_id does not exist" do
      lambda do
        EWS::Service.move_item!('does-not-exist', ['whatever'])
      end.should raise_error(EWS::ResponseError, /Id is malformed/)      
    end
  end

  context "EWS.inbox" do
    it "#each_message should iterate through the inbox without errors" do
      # lame test but will help protect against a regression until a
      # proper inbox setup is complete
      count = 0
      EWS.inbox.each_message {|m| count += 1}
      count.should > 0
    end

    it "#folders return the Inbox's folders without errors" do
      EWS.inbox.folders
    end
  end

end
