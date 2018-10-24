module Spree
  class CoinbaseController < StoreController
    skip_before_action :verify_authenticity_token, only: :callback
    before_action :load_coinbase_payment, only: :callback
    before_action :verify_request, only: :callback
    rescue_from Spree::Core::GatewayError, with: :rescue_from_spree_gateway_error

    def redirect
      @order = current_order
      if @order.persisted?
        if coinbase_payment = @order.payments.checkout.coinbase.first
          coinbase_payment.capture!
        end
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
          redirect_to spree.order_path(@order)
        else
          redirect_to checkout_state_path(@order.state)
        end
      else
        flash[:error] = Spree.t(:order_not_found)
        redirect_to root_path
      end
    end

    def callback
      @coinbase_payment.update(state: 'checkout')
      if params[:event][:type] == 'charge:confirmed' && @coinbase_payment.payment_method.can_capture?(@coinbase_payment)
        @coinbase_payment.update(state: 'checkout')
        @coinbase_payment.capture! rescue Spree::Core::GatewayError
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
        @coinbase_payment.payment_method.verify(request)
      end

      def rescue_from_spree_gateway_error(exception)
        flash[:error] = exception.message
        redirect_to checkout_state_path(@order.state)
      end

  end
end
