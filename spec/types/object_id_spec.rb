require_relative '../spec_helper'

module RASN1::Types

  describe ObjectId do
    describe '.type' do
      it 'gets ASN.1 type' do
        expect(ObjectId.type).to eq('OBJECT ID')
      end
    end

    describe '#initialize' do
      it 'creates a ObjectId with default values' do
        oi = ObjectId.new
        expect(oi).to be_primitive
        expect(oi).to_not be_optional
        expect(oi.asn1_class).to eq(:universal)
        expect(oi.default).to eq(nil)
      end
    end
    
    describe '#to_der' do
      it 'generates a DER string' do
        oi = ObjectId.new('1.2.3.4')
        expect(oi.to_der).to eq(binary("\x06\x03\x2a\x03\x04"))
        oi.value = '2.999.3'
        expect(oi.to_der).to eq(binary("\x06\x03\x88\x37\x03"))
      end

      it 'generates a DER string according to ASN.1 class' do
        oi = ObjectId.new('1.2.3.4', class: :context)
        expect(oi.to_der).to eq(binary("\x86\x03\x2a\x03\x04"))
      end

      it 'generates a DER string according to default' do
        oi = ObjectId.new(default: '1.2')
        oi.value = '1.2'
        expect(oi.to_der).to eq('')
        oi.value = '1.2.3'
        expect(oi.to_der).to eq(binary("\x06\x02\x2a\x03"))
      end

      it 'generates a DER string according to optional' do
        oi = ObjectId.new(optional: true)
        oi.value = nil
        expect(oi.to_der).to eq('')
        oi.value = '1.2.3'
        expect(oi.to_der).to eq(binary("\x06\x02\x2a\x03"))
      end

      it 'raises if first subidentifier is greater than 2' do
        oi = ObjectId.new
        oi.value = '3.1'
        expect { oi.to_der }.to raise_error(RASN1::ASN1Error, /less than 3/)
      end
      
      it 'raises if first subidentifier is lesser than 2 and second is greater than 39' do
        oi = ObjectId.new
        oi.value = '0.39'
        expect { oi.to_der }.to_not raise_error
        oi.value = '0.40'
        expect { oi.to_der }.to raise_error(RASN1::ASN1Error, /less than 40/)
        oi.value = '1.40'
        expect { oi.to_der }.to raise_error(RASN1::ASN1Error, /less than 40/)
        oi.value = '2.40'
        expect { oi.to_der }.to_not raise_error
      end
      
    end

    describe '#parse!' do
      let(:oi) { ObjectId.new }

      it 'parses a DER OCTET STRING' do
        oi.parse!(binary("\x06\x03\x2a\x03\x04"))
        expect(oi.value).to eq(binary('1.2.3.4'))
        oi.parse!(binary("\x06\x06\x7f\x81\x00\x83\xfb\x68"))
        expect(oi.value).to eq(binary('2.47.128.65000'))
        oi.parse!(binary("\x06\x03\x88\x37\x03"))
        expect(oi.value).to eq(binary('2.999.3'))
        oi.parse!(binary("\x06\x04\x86\x8d\x1f\x03"))
        expect(oi.value).to eq(binary('2.99919.3'))
      end
    end
  end
end
