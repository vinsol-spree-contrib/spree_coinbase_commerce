require 'httparty'

module Spree
  class CoinbaseController < StoreController
    skip_before_action :verify_authenticity_token, only: :callback
    before_action :verify_request, only: :callback
    before_action :load_coinbase_payment, only: :callback

    def redirect
      @order = current_order || raise(ActiveRecord::RecordNotFound)

      if coinbase_payment = @order.payments.checkout.coinbase.first
        coinbase_payment.capture!
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to checkout_state_path(@order.state)
        end
      else
        redirect_to edit_order_checkout_url(order, :state => 'payment'), :notice => Spree.t(:spree_coinbase_checkout_error)
      end
    end

    def callback
      if params[:event][:type] == 'charge:confirmed'
        @coinbase_payment.update(state: 'checkout') unless @coinbase_payment.checkout?
        @coinbase_payment.capture!
      end
      render text: "Callback successful"
    end

    private
      def load_coinbase_payment
        if params[:event] && params[:event][:data] && params[:event][:data][:code]
          @coinbase_payment = Spree::Payment.coinbase.find_by_response_code(params[:event][:data][:code])
        end
        raise(ActiveRecord::RecordNotFound) unless @coinbase_payment
      end

      def verify_request
        @coinbase_payment.payment.payment_method.verify(request)
      end

  end
end
