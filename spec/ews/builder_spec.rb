require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module BuilderHelper
  def builder(opts = {})
    EWS::Builder.new(@doc, opts)
  end
end

describe EWS::Builder do
  include BuilderHelper
  
  before(:each) do
    @doc = new_document
  end      

  context '#item_id! should build ItemId' do
    def expected_item_id
      %Q|<t:ItemId #{TNS} Id="XYZ" />|
    end

    def expected_item_id_with_change_key
      %Q|<t:ItemId #{TNS} ChangeKey="123" Id="XYZ" />|
    end
    
    it "given an id" do
      builder.item_id!(@doc, 'XYZ')
      @doc.to_s.should == expected_item_id
    end

    it "with a ChangeKey whe the :change_key option is given" do
      builder.item_id!(@doc, 'XYZ', :change_key => '123')
      @doc.to_s.should == expected_item_id_with_change_key
    end
  end
  
  context '#folder_id!' do
    context 'should build FolderId' do
      def expected_folder_id
        %Q|<t:FolderId #{TNS} Id="XYZ" />|
      end

      def expected_folder_id_with_change_key
        %Q|<t:FolderId #{TNS} ChangeKey="123" Id="XYZ" />|
      end
      
      it "given an id" do
        builder.folder_id!(@doc, 'XYZ')
        @doc.to_s.should == expected_folder_id
      end
      
      it "with a ChangeKey whe the :change_key option is given" do
        builder.folder_id!(@doc, 'XYZ', :change_key => '123')
        @doc.to_s.should == expected_folder_id_with_change_key
      end
    end
  
    context "should build a DistinguishedFolderId" do
      def expected_distinguished_folder_id(id)
        %Q|<t:DistinguishedFolderId #{TNS} Id="#{id}" />|
      end
      
      def expected_distinguished_folder_id_with_change_key
        %Q|<t:DistinguishedFolderId #{TNS} ChangeKey="222" Id="inbox" />|
      end
    
      EWS::DistinguishedFolders.each do |folder|
        it "given #{folder.inspect}" do
          builder.folder_id!(@doc, folder)
          @doc.to_s.should == expected_distinguished_folder_id(folder)
        end
      end
      
      it "with a ChangeKey when given the :change_key option" do
        builder.folder_id!(@doc, :inbox, :change_key => '222')
        @doc.to_s.should == expected_distinguished_folder_id_with_change_key
      end
    end
  end
  
  context "#folder_id_container should bulid the container node" do
    def expected_parent_folder_ids_with_one
      (<<-EOS
<tns:ParentFolderIds #{MNS}>
  <t:FolderId #{TNS} Id="111" />
</tns:ParentFolderIds>
EOS
      ).chomp
    end

    def expected_parent_folder_ids_with_one_distinguished
          (<<-EOS
<tns:ParentFolderIds #{MNS}>
  <t:DistinguishedFolderId #{TNS} Id="inbox" />
</tns:ParentFolderIds>
EOS
      ).chomp  
    end
    
    def expected_parent_folder_ids_with_more
      (<<-EOS
<tns:ParentFolderIds #{MNS}>
  <t:FolderId #{TNS} Id="111" />
  <t:DistinguishedFolderId #{TNS} Id="inbox" />
</tns:ParentFolderIds>
EOS
       ).chomp
    end
        
    it "when given one id" do
      builder.folder_id_container! 'tns:ParentFolderIds', '111'
      @doc.to_s.should == expected_parent_folder_ids_with_one
    end

    it "when given one distinguished folder" do
      builder.folder_id_container! 'tns:ParentFolderIds', :inbox
      @doc.to_s.should == expected_parent_folder_ids_with_one_distinguished
    end

    it "when given an array of ids" do
      builder.folder_id_container! 'tns:ParentFolderIds', ['111', :inbox]
      @doc.to_s.should == expected_parent_folder_ids_with_more
    end
  end

  context '#indexed_page_item_view!' do
    it "when given a limit" do
      builder.indexed_page_item_view!(:limit => 6)
      @doc.to_s.should == '<tns:IndexedPageItemView BasePoint="Beginning" xmlns:tns="http://schemas.microsoft.com/exchange/services/2006/messages" MaxEntriesReturned="6" Offset="0" />'
    end
    it "when given an offset" do
      builder.indexed_page_item_view!(:offset => 42)
      @doc.to_s.should == '<tns:IndexedPageItemView BasePoint="Beginning" xmlns:tns="http://schemas.microsoft.com/exchange/services/2006/messages" Offset="42" />'
    end
    it "when given a limit and offset" do
      builder.indexed_page_item_view!(:offset => 42, :limit => 6)
      @doc.to_s.should == '<tns:IndexedPageItemView BasePoint="Beginning" xmlns:tns="http://schemas.microsoft.com/exchange/services/2006/messages" MaxEntriesReturned="6" Offset="42" />'
    end
    it "when given no relevant parameters" do
      builder.indexed_page_item_view!({})
      proc { @doc.to_s }.should raise_error(StandardError, /document element/)
    end
  end

  context '#query_string!' do
    it "when given a query" do
      builder.query_string!(:to => 'fred.nerk@example.com')
      @doc.to_s.should =~ /Restriction.+Contains.+FieldURI FieldURI="message:ToRecipients" \/>.+<t:Constant Value="fred.nerk@example.com"/m
    end
    it "when given a query including participants" do
      builder.query_string!(:participants => 'fred.nerk@example.com')
      @doc.to_s.should == "<tns:Restriction xmlns:tns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\n  <t:Or xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n    <t:Contains ContainmentMode=\"Substring\" ContainmentComparison=\"IgnoreCaseAndNonSpacingCharacters\">\n      <t:FieldURI FieldURI=\"message:From\" />\n      <t:Constant Value=\"fred.nerk@example.com\" />\n    </t:Contains>\n    <t:Contains ContainmentMode=\"Substring\" ContainmentComparison=\"IgnoreCaseAndNonSpacingCharacters\">\n      <t:FieldURI FieldURI=\"message:ToRecipients\" />\n      <t:Constant Value=\"fred.nerk@example.com\" />\n    </t:Contains>\n    <t:Contains ContainmentMode=\"Substring\" ContainmentComparison=\"IgnoreCaseAndNonSpacingCharacters\">\n      <t:FieldURI FieldURI=\"message:CcRecipients\" />\n      <t:Constant Value=\"fred.nerk@example.com\" />\n    </t:Contains>\n    <t:Contains ContainmentMode=\"Substring\" ContainmentComparison=\"IgnoreCaseAndNonSpacingCharacters\">\n      <t:FieldURI FieldURI=\"message:BccRecipients\" />\n      <t:Constant Value=\"fred.nerk@example.com\" />\n    </t:Contains>\n  </t:Or>\n</tns:Restriction>"
    end
    it "when given nil" do
      builder.query_string!(nil)
      proc { @doc.to_s }.should raise_error(StandardError, /document element/)
    end
    it "when given an empty hash" do
      builder.query_string!({})
      proc { @doc.to_s }.should raise_error(StandardError, /document element/)
    end
  end
  
end
