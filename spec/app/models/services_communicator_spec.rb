require './spec/spec_helper'

class ServicesCommunicatorSpec < StsProxySpec
  describe ServicesCommunicator do
    let(:json_params) { { 'number' => 11111} }
    let(:url_params) { {'Merchant_Number' => 111, 'Terminal_ID' => 111, 'Action_Code' => 05} }
    let(:action) { :check_balance }
    let(:sts_url) { 'https://www.smart-transactions.com/testgateway.php' }

    let(:subject) { ServicesCommunicator.new(json_params, url_params, action) }

    let(:renamed_params) { subject.send(:rename_params, json_params, action) }
    let(:combined_params) { subject.send(:combine_params, renamed_params, url_params) }
    let(:formatted_to_xml) { subject.send(:change_format, combined_params, :hash, :xml) }
    let(:received_data) { subject.send(:send_data, formatted_to_xml, sts_url) }
    let(:formatted_to_hash) { subject.send(:change_format, received_data, :xml, :hash) }
    let(:filtered_data) { subject.send(:filter_data, formatted_to_hash, action) }

    describe '#run' do
      it 'returns a data hash from a remote server' do
        assert_equal subject.run, { "balance" => "0.00" }
      end
    end

    describe '#rename_params' do
      it 'returns renamed hash params for a certain action' do
        assert_equal renamed_params, { 'Card_Number' => 11111 }
      end
    end

    describe '#combine_params' do
      it 'returns two combined hashes' do
        assert_equal combined_params,
                     { 'Card_Number' => 11111, 'Merchant_Number' => 111, 'Terminal_ID' => 111, 'Action_Code' => 05 }
      end
    end

    describe '#change_format' do
      let(:expected_xml) do
        xml_builder = Builder::XmlMarkup.new(indent: 2)
        xml_builder.instruct! :xml, version: '1.0', encoding: 'UTF-8'
        xml_builder.tag!('Request') {
          xml_builder.tag! 'Card_Number', 11111
          xml_builder.tag! 'Merchant_Number', 111
          xml_builder.tag! 'Terminal_ID', 111
          xml_builder.tag! 'Action_Code', 05
        }
      end

      let(:expected_hash) { { "Response" => { "Response_Code" => "00", "Response_Text" => "311421",
                                              "Auth_Reference" => "0001", "Amount_Balance" => "0.00",
                                              "Expiration_Date" => "092429", "Trans_Date_Time" => "060710105839",
                                              "Card_Number" => "711194103319309", "Transaction_ID" => "56" } } }

      it 'converts hash to xml' do
        assert_equal formatted_to_xml, expected_xml
      end

      it 'converts xml to hash' do
        assert_equal formatted_to_hash, expected_hash
      end
    end

    describe '#send_data' do
      it 'returns data from a remote url' do
        skip 'must receive real response'
        assert_equal received_data, 'real response'
      end
    end

    describe '#filter_data' do
      it 'returns only a required data for a certain action' do
        assert_equal filtered_data, { "balance" => "0.00" }
      end
    end
  end
end