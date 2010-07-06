module EWS  

  class Folder < Model
    def id
      attrs[:folder_id][:id]
    end

    def change_key
      attrs[:folder_id][:change_key]
    end

    def name
      attrs[:display_name]
    end

    def each_message
      items.each {|message| yield message }
    end

    def folders
      @folders ||= find_folders.inject({}) do |folders, folder|
        folders[folder.name] = folder
        folders
      end
    end

    # Find items belonging to this folder.
    #
    # @param [Hash] opts Options to manipulate the request
    # @option :limit Maximum number of items to return
    # @option :offset Number of items to skip (for paged results)
    # @option :query_string Restrict items returned by matching search terms.
    #   Fields include :to, :cc, :bcc, :subject, :body, :content, :attachment,
    #   :participants.
    #
    # @example folder.items :limit => 20, :query_string => {:participants => 'fred@example.com', :subject => 'TPS Report'}
    def items(opts = {})
      @items ||= {}
      @items[opts] ||= find_folder_items(opts)
    end
    
    private
    def find_folder_items(opts = {})
      # NOTE: This assumes Service#find_item only returns
      # Messages. That is true now but will change as more
      # of the parser is implemented.
      service.find_item(self.id, opts.merge(:base_shape => :AllProperties))
    end

    def find_folders
      service.find_folder(self.id)
    end
  end
  
end
