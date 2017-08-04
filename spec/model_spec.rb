require 'spec_helper'

module RASN1

  class ModelTest < Model
    sequence :record,
             content: [integer(:id),
                       integer(:room, implicit: 0, optional: true),
                       integer(:house, explicit: 1, default: 0)]
  end

  class ModelTest2 < Model
    sequence :record2,
             content: [boolean(:rented),
                       ModelTest]
  end

  SIMPLE_VALUE = "\x30\x0e\x02\x03\x01\x00\x01\x80\x01\x2b\x81\x04\x02\x02\x12\x34".force_encoding('BINARY')
  OPTIONAL_VALUE = "\x30\x0b\x02\x03\x01\x00\x01\x81\x04\x02\x02\x12\x34".force_encoding('BINARY')
  DEFAULT_VALUE = "\x30\x08\x02\x03\x01\x00\x01\x80\x01\x2b".force_encoding('BINARY')
  NESTED_VALUE = "\x30\x0d\x01\x01\xff\x30\x08\x02\x03\x01\x00\x01\x80\x01\x2b".force_encoding('BINARY')
  ERRORED_VALUE = "\x01\x01\x00"

  describe Model do
    describe '#initialize' do
      it 'creates a class from a Model' do
        expect { ModelTest.new }.to_not raise_error
      end
    end

    describe '#name' do
      it 'returns name of root element' do
        expect(ModelTest.new.name).to eq(:record)
      end
    end

    describe '#to_h' do
      it 'generates a Hash image of model' do
        test = ModelTest.new
        test[:id].value = 12
        test[:room].value = 3
        expect(test.to_h).to eq({ record: { id: 12, room: 3, house: 0 } })
      end

      it 'generates a Hash image of a nested model' do
        test2 = ModelTest2.new
        test2[:rented].value = true
        test2[:record][:id].value = 12
        test2[:record][:house].value = 1
        expect(test2.to_h).to eq({ record2: { rented: true,
                                              record:
                                                { id: 12, house: 1 }
                                            }
                                 })
      end
    end

    describe '#to_der' do
      it 'generates a DER string from a simple model' do
        test = ModelTest.new(id: 65537, room: 43, house: 0x1234)
        expect(test.to_der).to eq(SIMPLE_VALUE)
      end

      it 'generates a DER string from a simple model, without optional value' do
        test = ModelTest.new(id: 65537, house: 0x1234)
        expect(test.to_der).to eq(OPTIONAL_VALUE)
      end

      it 'generates a DER string from a simple model, without default value' do
        test = ModelTest.new(id: 65537, room: 43)
        expect(test.to_der).to eq(DEFAULT_VALUE)
      end
      it 'generates a DER string from a nested model' do
        test2 = ModelTest2.new(rented: true, record: { id: 65537, room: 43 })
        expect(test2.to_der).to eq(NESTED_VALUE)
      end
    end

    describe '.parse' do
      it 'parses a DER string from a simple model' do
        test = ModelTest.parse(SIMPLE_VALUE)
        expect(test[:id].value).to eq(65537)
        expect(test[:room].value).to eq(43)
        expect(test[:house].value).to eq(0x1234)
      end

      it 'parses a DER string from a simple model, optional value being not present' do
        test = ModelTest.parse(OPTIONAL_VALUE)
        expect(test[:id].value).to eq(65537)
        expect(test[:room].value).to eq(nil)
        expect(test[:house].value).to eq(0x1234)
      end

      it 'parses a DER string from a simple model, default value being not present' do
        test = ModelTest.parse(DEFAULT_VALUE)
        expect(test[:id].value).to eq(65537)
        expect(test[:room].value).to eq(43)
        expect(test[:house].value).to eq(0)
      end

      it 'parses a DER string from a nested model' do
        test2 = ModelTest2.parse(NESTED_VALUE)
        expect(test2.to_h).to eq(record2: { rented: true,
                                            record: { id: 65537,
                                                      room: 43,
                                                      house: 0 }
                                          })
      end
    end
  end
end
