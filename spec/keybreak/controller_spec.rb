require 'spec_helper'

describe Keybreak do
  
  
  describe '::Controller' do
    
    
    before :each do
      @c = Keybreak::Controller.new
    end
    
    
    context 'when an instance is created' do
    
      describe '#initialize' do
        it 'should not be nil' do
          expect(@c).not_to be nil
        end
      end
    
    end # context
    
    
    context 'when user does not provide event handlers' do
    
      describe '#feed' do
        it 'does nothing' do
          expect { @c.feed(1) }.to output("").to_stdout
        end
      end
      
      describe '#flush' do      
        it 'does nothing' do
          expect { @c.flush }.to output("").to_stdout
        end
        
        it 'does nothing even once fed a key' do
          expect do
            @c.feed(1)
            @c.flush
          end.to output("").to_stdout
        end
      end
      
      describe '#execute' do      
        it 'does nothing except the given block' do
          expect do
            @c.execute { print "abc"}
          end.to output("abc").to_stdout
        end
      end
    
    end # context
    
    
    context 'when user provides a :keystart handler' do
      
      describe '#feed' do
      
        context 'when key break occurs' do
        
          it 'calls the :keystart handler' do
            @c.on(:keystart) { |k| print "KEYSTART #{k}" }
            
            expect do
              @c.feed(nil)
            end.to output("KEYSTART ").to_stdout
            
            expect do
              @c.feed(1)
            end.to output("KEYSTART 1").to_stdout
            
            expect do
              @c.feed(2)
            end.to output("KEYSTART 2").to_stdout
          end
          
          it 'calls the :keystart handler with an optional parameter' do
            @c.on(:keystart) { |k, v| print "KEYSTART #{k}+#{v}" }
          
            expect do
              @c.feed(1, "a")
            end.to output("KEYSTART 1+a").to_stdout
          
            expect do
              @c.feed(2, "b", "xyz")
            end.to output("KEYSTART 2+b").to_stdout
          end
        
          it 'calls the :keystart handler with optional parameters' do
            @c.on(:keystart) { |k, v1, v2| print "KEYSTART #{k}+#{v1}+#{v2}" }
          
            expect do
              @c.feed(1, "a")
            end.to output("KEYSTART 1+a+").to_stdout
          
            expect do
              @c.feed(2, "b", "xyz")
            end.to output("KEYSTART 2+b+xyz").to_stdout
          end
          
        end
        
        
        it 'calls the :keystart handler only when key break occurs' do
          @c.on(:keystart) { |k| print "#{k}" }
          
          expect do
            @c.feed(3)
            @c.feed(3)
            @c.feed(2)
            @c.feed(1)
            @c.feed(1)
          end.to output("321").to_stdout
        end
      end
      
      
      describe '#flush' do
        it 'does nothing' do
          @c.on(:keystart) { }
          @c.feed(1)
          
          expect do
            @c.flush
          end.to output("").to_stdout
        end
      end
      
      
      describe '#execute' do
        it 'calls the :keystart handler when key break occurs' do
          @c.on(:keystart) { |k, v| print "#{k}+#{v}"}
          
          expect do
            @c.execute do
              feed(1, "a")
              feed(2, "b")
            end
          end.to output("1+a2+b").to_stdout
        end
      end
      
      
      describe '#on' do
        it 'returns the instance itself' do
          expect(@c.on(:keystart) { |k, v| print "#{k}+#{v}"}).to eq(@c)
        end
      end
      
    end # context
    
    
    
    
    context 'when user provides a :keyend handler' do
      
      describe '#feed' do
        it 'does not call the :keyend handler for the first fed key' do
          @c.on(:keyend) { |k| print "KEYEND #{k}" }
          
          expect do
            @c.feed(1)
          end.to output("").to_stdout
        end
        
        context 'when key break occurs' do
        
          it 'calls the :keyend handler with the previsous key' do
            @c.on(:keyend) { |k| print "KEYEND #{k}" }
            
            expect do
              @c.feed(1)
            end.to output("").to_stdout
            
            expect do
              @c.feed(2)
            end.to output("KEYEND 1").to_stdout
          end
          
          it 'calls the :keyend handler with previous optional parameter' do
            @c.on(:keyend) { |k, v| print "KEYEND #{k}+#{v}" }
            @c.feed(1, "a")
          
            expect do
              @c.feed(2, "b")
            end.to output("KEYEND 1+a").to_stdout
          end
          
          it 'calls the :keyend handler except at the end of the last key' do
            @c.on(:keyend) { |k| print "#{k}" }
          
            expect do
              @c.feed(3)
              @c.feed(3)
              @c.feed(2)
              @c.feed(1)
              @c.feed(1)
            end.to output("32").to_stdout
          end
          
        end #context
      end
      
      describe '#flush' do

        it 'does nothing when key break did not occur' do
          @c.on(:keyend) { |k| print "#{k}"}
          @c.feed(nil)
          
          expect do
            @c.flush
          end.to output("").to_stdout
        end
        
        context 'once key break occurred' do
          
          it 'calls the :keyend handler with the last key' do
            @c.on(:keyend) { |k| print "#{k}"}
            @c.feed(1)
            
            expect do
              @c.feed(2)
            end.to output("1").to_stdout
            
            expect do
              @c.flush
            end.to output("2").to_stdout
          end
          
          it 'calls the :keyend handler with the last key and the last parameter' do
            @c.on(:keyend) { |k, v| print "#{k}+#{v}"}
            @c.feed(1, "a")
            @c.feed(1, "b")
            
            expect do
              @c.flush
            end.to output("1+b").to_stdout
          end
          
        end #context
      end
      
      describe '#execute' do
        
        context 'once keybreak occurred' do
          
          it 'calls :keyend hander with the last key and the last parameter' do
            @c.on(:keyend) { |k, v| print "#{k}+#{v}"}
            
            expect do
              @c.execute do
                feed(1, "a")
                feed(1, "b")
              end
            end.to output("1+b").to_stdout
          end
        
        end #context
      
      end
      
      
      describe '#on' do
        it 'returns the instance itself' do
          expect(@c.on(:keyend) { |k, v| print "#{k}+#{v}"}).to eq(@c)
        end
      end
      
      
    end # context
    
    context 'when user provides handlers for both :keystart and :keyend' do
      
      describe '#feed' do
        
        it 'calls the :keyend handler first, and next, calls the :keystart handler' do
          @c.on(:keystart) { |k, v| print "KEYSTART #{k}+#{v}"}
          @c.on(:keyend) { |k, v| print "KEYEND #{k}+#{v}"}
          
          expect do
            @c.feed(1, "a")
            @c.feed(2, "b")
          end.to output("KEYSTART 1+aKEYEND 1+aKEYSTART 2+b").to_stdout
        end
        
        it 'does nothing when key break does not occur' do
          @c.feed(1)
          @c.on(:keystart) { |k, v| print "KEYSTART #{k}+#{v}"}
          @c.on(:keyend) { |k, v| print "KEYEND #{k}+#{v}"}
          
          expect do
            @c.feed(1, "b")
            @c.feed(1, "c")
          end.to output("").to_stdout
        end
        
      end
      
      describe '#flush' do
        it 'calls the :keyend handler with the last key and the last parameter once key break occurred' do
          @c.on(:keystart) { |k, v| print "KEYSTART #{k}+#{v}"}
          @c.on(:keyend) { |k, v| print "KEYEND #{k}+#{v}"}
          
          expect do
            @c.feed(1, "a")
            @c.feed(2, "b")
          end.to output("KEYSTART 1+aKEYEND 1+aKEYSTART 2+b").to_stdout
          
          expect do
            @c.flush
          end.to output("KEYEND 2+b").to_stdout
        end
      end
      
      
      describe '#execute' do
        it 'calls the :keystart handler at first key break and the keyend process at last' do
          @c.on(:keystart) { |k, v| print "#{k}+#{v}"}
          @c.on(:keyend) { |k, v| print "#{k}+#{v}"}
          
          expect do
            @c.execute do
              feed(1, "a")
              feed(1, "b")
            end
          end.to output("1+a1+b").to_stdout
        end
      end
      
      
    end #context
    
    
    context 'when user provides a :detection handler' do
      
      
      describe '#feed' do
        
        it 'can detect key break with only a key' do
          @c.on(:detection) {|key| key > 0}
          @c.on(:keystart) { |k, v| print "#{k}+#{v}"}  
        
          expect do
            @c.feed(0, "a")
            @c.feed(-1, "b")
            @c.feed(0, "c")
            @c.feed(1, "d")
          end.to output("0+a1+d").to_stdout
        end
        
        it 'receives current key and previous key' do
          @c.on(:detection) do |key, prev_key|
            print "#{key}+#{prev_key}"
            key != prev_key
          end
        
          expect do
            @c.feed(1, "a")
            @c.feed(1, "b")
            @c.feed(2, "c")
            @c.feed(3, "d")
          end.to output("1+12+13+2").to_stdout
        end
      end
      
      
    end
    
  end #class
  
  
end #module

# EOF
