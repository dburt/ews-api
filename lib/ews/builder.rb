require 'forwardable'

module EWS
  
  # AdditionalProperties
  # @see http://msdn.microsoft.com/en-us/library/aa580545(EXCHG.80).aspx
  # BaseShape  
  # @see http://msdn.microsoft.com/en-us/library/aa565622(EXCHG.80).aspx
  # BodyType
  # @see http://msdn.microsoft.com/en-us/library/aa580499(EXCHG.80).aspx
  # IncludeMimeContent  
  class Builder
    extend Forwardable

    def_delegators :@resolve_names_builder,
                   :unresolved_entry!,
                   :return_full_contact_data!

    def_delegators :@shape_builder,
                   :item_shape!,
                   :folder_shape!,
                   :attachment_shape!
    
    def initialize(action_node, opts, &block)
      @action_node, @opts = action_node, opts
      @resolve_names_builder = ResolveNamesBuilder.new(action_node)
      @shape_builder = ShapeBuilder.new(action_node, opts)
      instance_eval(&block) if block_given?
    end
        
    def item_id_container!(container_node_name, item_ids)
      id_container!(container_node_name, item_ids) do |container_node, id|
        item_id! container_node, id, @opts
      end
    end

    def folder_id_container!(container_node_name, folder_ids)
      id_container!(container_node_name, folder_ids) do |container_node, id|
        folder_id! container_node, id, @opts
      end
    end

    def attachment_ids!(attachment_ids)
      id_container!('tns:AttachmentIds', attachment_ids) do |container_node, id|
        id_node! container_node, 't:AttachmentId', id
      end
    end
    
    def id_container!(container_node_name, ids)
      @action_node.add(container_node_name) do |container_node|
        Array(ids).each {|id| yield container_node, id }
      end
    end

    def traversal!
      @action_node.set_attr 'Traversal', (@opts[:traversal] || :Shallow) 
    end        

    # Add result pagination to the FindItem or FindFolder request parameters
    #
    # @example @opts = {:limit => 20, :offset => 0}
    # @see http://msdn.microsoft.com/en-us/library/aa563549.aspx IndexedPageItemView
    def indexed_page_item_view!(opts=@opts)
      if opts[:offset] || opts[:limit]
        @action_node.add 'tns:IndexedPageItemView' do |view|
          view.set_attr 'MaxEntriesReturned', opts[:limit] if opts[:limit]
          view.set_attr 'BasePoint', 'Beginning'
          view.set_attr 'Offset', (opts[:offset] || 0)
        end
      end
    end

    def sort_order!
      raise "TODO"
    end

    # Add a Restriction to the FindItem or FindFolder request parameters
    #
    # @example @opts = {:query_string => {:participants => 'fred@example.com'}
    # recognized fields: to, cc, bcc, subject, body, content, attachment,
    #   participants
    # @see http://msdn.microsoft.com/en-us/library/ee693615.aspx QueryString
    # @see http://msdn.microsoft.com/en-us/library/aa563791.aspx Restriction
    def query_string!(qs = @opts[:query_string])
      if qs && !qs.empty?
        @action_node.add 'tns:Restriction' do |restriction|
          if qs.size == 1
            query_string_fields! restriction, qs
          else
            restriction.add 't:And' do |_and|
              query_string_fields! _and, qs
            end
          end
        end
      end
    end

    def query_string_fields! node, qs
      participants! node, qs[:participants] if qs[:participants]
      { :to => 'message:ToRecipients', :cc => 'message:CcRecipients',
        :bcc => 'message:BccRecipients', :subject => 'item:Subject',
        :body => 'item:Body', :content => 'item:Body',
        :attachment => 'item:Attachments' }.each do |key, field_uri|
        contains! node, field_uri, qs[key] if qs[key]
      end
    end

    def participants!(node, participant)
      node.add 't:Or' do |_or|
        %w[From ToRecipients CcRecipients BccRecipients].each do |fld|
          contains! _or, "message:#{fld}", participant
        end
      end
    end

    def contains!(node, field, value)
      node.add 't:Contains' do |contains|
        contains.set_attr 'ContainmentMode', :Substring
        contains.set_attr 'ContainmentComparison', :IgnoreCaseAndNonSpacingCharacters
        contains.add 't:FieldURI' do |field_uri|
          field_uri.set_attr 'FieldURI', field
        end
        contains.add 't:Constant' do |constant|
          constant.set_attr 'Value', value
        end
      end
    end

    # @see http://msdn.microsoft.com/en-us/library/aa580234(EXCHG.80).aspx
    # ItemId
    def item_id!(container_node, item_id, opts = {})
      id_node! container_node, 't:ItemId', item_id, opts
    end
        
    # @param parent [Handsoap::XmlMason::Node]
    #
    # @param folder_id [String, Symbol] When a EWS::DistinguishedFolder a
    # DistinguishedFolderId is created otherwise FolderId is used
    #
    # @param [Hash] opts
    # @option opts [Symbol] :change_key
    #
    # @see http://msdn.microsoft.com/en-us/library/aa580808(EXCHG.80).aspx
    # DistinguishedFolderId
    #   
    # @see http://msdn.microsoft.com/en-us/library/aa579461(EXCHG.80).aspx
    # FolderId
    def folder_id!(container_node, folder_id, opts = {})
      node_name = if DistinguishedFolders.include?(folder_id)
        't:DistinguishedFolderId'
      else
        't:FolderId'
      end
      id_node! container_node, node_name, folder_id, opts
    end

    # @param opts [Hash] Still an argument so opts can remain optional
    def id_node!(container_node, id_node_name, id, opts = {})
      container_node.add(id_node_name) do |id_node|
        id_node.set_attr 'Id', id        
        id_node.set_attr 'ChangeKey', opts[:change_key] if opts[:change_key]
      end 
    end
  end
  
end
