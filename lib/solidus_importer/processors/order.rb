# frozen_string_literal: true

module SolidusImporter
  module Processors
    class Order < Base
      def call(context)
        @data = context.fetch(:data)
        context.merge!(check_data || save_order)
      end

      def options
        @options ||= {
          store: Spree::Store.default
        }
      end

      private

      def check_data
        { success: false, messages: 'Missing required key: "Name"' } if @data['Name'].blank?
      end

      def prepare_order
        order = Spree::Order.find_or_initialize_by(number: @data['Name']) do |ord|
          ord.store = options[:store]
        end
        order.currency = @data['Currency'] unless @data['Currency'].nil?
        order.email = @data['Email'] unless @data['Email'].nil?
        order.special_instructions = @data['Note'] unless @data['Note'].nil?
        order
      end

      def save_order
        order = prepare_order
        {
          new_record: order.new_record?,
          success: order.save,
          order: order,
          messages: order.errors.full_messages.join(', ')
        }
      end
    end
  end
end