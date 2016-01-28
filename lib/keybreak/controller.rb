# coding: utf-8

module Keybreak
  
  # Controller of keybreak processing
  class Controller

    # Generate an instance
    def initialize()
      clear
      @handlers = {}
      @handlers[:keystart] = DO_NOTHING
      @handlers[:keyend] = DO_NOTHING
    end
    
    
    # Registers the given block as a keybreak event handler
    # Valid keybreak events are:
    #   :keystart
    #   :keyend
    def on(event, &block)
      @handlers[event] = block
    end
    
    
    # Detects keybreak and calls the registered handlers
    # When a new key comes, call the keyend handler with the last key and value,
    #   then call the keystart handler with the new key and value
    # For the first key feed, does not call the keyend handler
    # Use flush() to call the keyend handler for the last fed key
    def feed(key, *values)
      if @is_fed
        if key != @key
          @handlers[:keyend].call(@key, *@values)
          @key = key
          @handlers[:keystart].call(key, *values)
        end
      else
        @is_fed = true
        @key = key
        @handlers[:keystart].call(key, *values)
      end
      
      @values = values
    end
    
    
    # Clears internal data to the status before key feed starts
    def clear()
      @is_fed = false
      @values = []
    end
    
    
    # Calls the keyend handler once with the last fed key and value,
    #   then clears internal data to the status before key feed starts
    # Place this method after the last feed() to complete keybreak process
    # Does nothing when no key has been fed
    def flush()
      if @is_fed
        @handlers[:keyend].call(@key, *@values)
      end
      
      clear
    end
    
    
    # Executes the given block and calls flush() finally
    # Place feed() within the block so that the keybreak handlers are
    #  called for all keys including the last key
    def execute(&block)
      instance_eval(&block)
      self.flush
    end

  end # class

end # module

# EOF
