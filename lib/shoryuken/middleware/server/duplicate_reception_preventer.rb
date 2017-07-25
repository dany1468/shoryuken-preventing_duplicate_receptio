module Shoryuken
  module Middleware
    module Server
      class DuplicateReceptionPreventer
        def initialize(table_name:, hash_key_attr:, ttl_attr:, client: nil)
          @lock ||= Shoryuken::PreventingDuplicateReception::DynamodbLock.new(table_name, hash_key_attr, ttl_attr, client)
        end

        def call(_worker, _queue, sqs_msg, _body)
          @lock.with_lock(sqs_msg.message_id) do
            yield
          end
        end
      end
    end
  end
end
