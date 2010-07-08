require File.dirname(__FILE__) + '/../spec_helper'

module EWS
  
  describe Message do
    before(:each) do
      @parser = Parser.new
      @message = @parser.parse_get_item response_to_doc(:get_item_all_properties)
    end
    
    it "#id should be the item_id id" do
      @message.id.should == 'HRlZ'
    end

    it "#change_key should be the item_id change_key" do
      @message.change_key.should == '0Tk4V'
    end

    it "should be able to move itself to the give folder id" do
      id = 'xyz'
      folder_id = '123'
      Service.should_receive(:move_item!).with(folder_id, [id])

      Message.new(:item_id => {:id => id}).move_to!(folder_id)
    end

    it "should have from address" do
      @message.from.should == '"Mail Delivery System" <DAEMON@example.com>'
    end

    it "should have recipients" do
      @message.recipients.should == ['"sansa@example.com" <sansa@example.com>']
    end

    it "should have other fields from returned data" do
      {
        :is_read_receipt_requested => false,
        :is_read => true,
        :date_time_sent => DateTime.new(2009, 12, 2, 16, 38, 47),
        :item_class => "REPORT.IPM.Note.NDR",
        :sensitivity => "Normal",
        :size => "5496",
        :culture => "en-US"
      }.each do |method, result|
        @message.send(method).should == result
      end
    end
  end
  
end
