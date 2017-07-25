# frozen_string_literal: true

RSpec.describe Shoryuken::Middleware::Server::DuplicateReceptionPreventer do
  let(:lock_table_name) { 'sample_queue_lock' }
  let(:lock_hash_key_attr) { 'message_id' }
  let(:lock_ttl_attr) { 'received_at' }
  let(:client) {
    Aws::DynamoDB::Client.new(endpoint: 'http://dynamodb:8000', region: 'us-east-1')
  }

  before do
    client.delete_table(table_name: 'sample_queue_lock') rescue nil

    options = {
      table_name: lock_table_name,
      key_schema: [
        {
          attribute_name: lock_hash_key_attr,
          key_type: 'HASH'
        }
      ],
      attribute_definitions: [
        {
          attribute_name: lock_hash_key_attr,
          attribute_type: 'S'
        }
      ],
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    }

    client.create_table(options)
  end

  let(:middleware) {
    Shoryuken::Middleware::Server::DuplicateReceptionPreventer.new(
      table_name: lock_table_name,
      hash_key_attr: lock_hash_key_attr,
      ttl_attr: lock_ttl_attr,
      client: client
    )
  }
  let(:sqs_msg) {
    double('sqs_msg').tap {|msg|
      allow(msg).to receive(:message_id) { '123' }
    }
  }

  context 'a sqs_msg has not been received yet' do
    specify do
      expect {|b| middleware.call(nil, nil, sqs_msg, nil, &b) }.to yield_control
    end
  end

  context 'a sqs_msg has already been received' do
    specify do
      lock = Shoryuken::PreventingDuplicateReception::DynamodbLock.new(lock_table_name, lock_hash_key_attr, lock_ttl_attr, client)
      lock.with_lock('123') do
        expect {|b| middleware.call(nil, nil, sqs_msg, nil, &b) }.not_to yield_control
      end
    end
  end
end
