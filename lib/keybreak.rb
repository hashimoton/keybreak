# coding: utf-8
require "keybreak/version"
require "keybreak/controller"

# Utilities for key break (control-break) processing
module Keybreak

  # The block which does nothing.
  DO_NOTHING = Proc.new {}
  
  
  # The default key break detector
  KEY_CHANGED = Proc.new {|key, prev_key| key != prev_key}
  
  
  # Executes the given block with a Controller instance.
  # Within the block, register your key break handlers and feed keys from your data.
  # Then the handlers will be called for all keys including the last key.
  def execute_with_controller(&block)
      Controller.new.execute(&block)
  end
  module_function :execute_with_controller

end
