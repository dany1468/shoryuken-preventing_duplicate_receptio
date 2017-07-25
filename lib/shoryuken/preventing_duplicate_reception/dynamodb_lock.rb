# frozen_string_literal: true

require 'aws-sdk-core'

module Shoryuken
  module PreventingDuplicateReception
    class DynamodbLock
      def initialize(table_name, hash_key_attr, ttl_attr, client = nil)
        @table_name = table_name
        @hash_key_attr = hash_key_attr
        @ttl_attr = ttl_attr
        @client = client
      end

      def with_lock(message_id)
        if acquire_lock(message_id)
          begin
            yield
          ensure
            release_lock message_id
          end
        else
          Shoryuken.logger.debug { "Could not acquire lock. table_name:#{@table_name} hash_key:#{@hash_key_attr} => #{message_id}" }
        end
      end

      def acquire_lock(message_id)
        client.put_item(
          item: {
            @hash_key_attr => message_id,
            @ttl_attr => Time.now.to_i,
          },
          condition_expression: "attribute_not_exists(#{@hash_key_attr})",
          table_name: @table_name
        )

        true
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
        false
      end

      def release_lock(message_id)
        client.delete_item(
          table_name: @table_name,
          key: {
            @hash_key_attr => message_id
          }
        )
      end

      private

      def client
        @client ||= Aws::DynamoDB::Client.new
      end
    end
  end
end
