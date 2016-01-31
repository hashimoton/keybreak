require 'spec_helper'

describe Keybreak do
  
  describe '::VERSION' do
    it 'has a version number' do
      expect(Keybreak::VERSION).not_to be nil
    end
  end
  
  describe '::DO_NOTHING' do
    it 'does nothing' do
      expect do
        Keybreak::DO_NOTHING
      end.to output("").to_stdout
    end
  end
  
  describe '::KEY_CHANGED' do
    it 'returns false when the key is equal to the previous key' do
      expect(Keybreak::KEY_CHANGED.call(1, 1)).to be(false)
    end
    
    it 'returns true when the key is equal to the previous key' do
      expect(Keybreak::KEY_CHANGED.call(1, 2)).to be(true)
    end
  end
  
  describe '.execute_with_controller' do
    it 'calls keybreak handlers including the keyend handler finally' do
      results = []

      Keybreak.execute_with_controller do |c|
        c.on(:keystart) { |k, v| results.push("START #{k}+#{v}")}
        c.on(:keyend) { |k, v| results.push("END #{k}+#{v}")}
        c.feed(1, "a")
        c.feed(1, "b")
        c.feed(1, "c")
        c.feed(2, "d")
      end
      
      expect(results).to eq(["START 1+a", "END 1+c", "START 2+d", "END 2+d"])
    end
  end
  
end

# EOF
