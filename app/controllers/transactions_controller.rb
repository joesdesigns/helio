class TransactionsController < ApplicationController
  
  require 'fuelsdk'

  before_filter :sso_redirect

  def index
    @trans = Transactions.new(current_user)
    @active_orders = @trans.active_orders
  end

  def refunds
    @trans = Transactions.new(current_user)
    @refunded_items = @trans.refunded_items
  end

  def details
    @trans = Transactions.new(current_user)
    @details = @trans.order_details(params[:id])
    @refunded_skus = @trans.refunded_skus
  end

  def item
    @trans = Transactions.new(current_user)
    @item = @trans.item_details(params[:id])
  end

  def request_refund
    reasons = params[:reason]
    reasons << "bad experience: #{params[:bad_experience]}" unless params[:bad_experience].blank?
    reasons << "other: #{params[:other]}" unless params[:other].blank?
    reason = reasons.to_sentence rescue "No Comments"

    @api  = VST::External::Jiffy.new(:access_token => current_user.access_token, :user_guid => current_user.guid)
    stat = @api.request_refund(:code => params[:code], :reason => 'undetermined', :transaction_number => params[:transid])
    if @api.success?
      current_time = DateTime.now
      args = {
        'triggered_send_id' => 'CSM_Triggered_ID11',
        'recipient_email' => current_user.email,
        'params' => {
          'product_isbn' => params[:isbn],
          'credit_amount' => (params[:item_price].to_f + params[:tax].to_f),
          'payment_method' => params[:credit_card_type],
          'credit_card_field' => params[:credit_card_number],
          'process_date' => current_time.strftime("%d/%m/%Y %H:%M")
        }
      }
      confirmation_email(args)

      flash[:status_success] = "Success"
    else
      flash[:status_fail] = "Unable to Process your refund at this time. Try Again later."
    end
     redirect_to transactions_path
  end

  def refund
    @api  = VST::External::Jiffy.new(:access_token => current_user.access_token, :user_guid => current_user.guid)
    @api.purchase_history
    @purchases = JSON.parse @api.response_body
    @refund = {}
    @purchases.each do |p|
      p['purchase_items'].each do |x|
        if x['code']==params[:code].to_s
          x['credit_card_number'] = p['credit_card_number']
          x['credit_card_type'] = p['credit_card_type']
          x['currency'] = p['currency']
          @refund = x
        end
      end
    end
    render layout: 'refund_confirmation'
  end

  def print
    # just print the contents of the order number specified with params[:id]
    @api  = VST::External::Jiffy.new(:access_token => current_user.access_token, :user_guid => current_user.guid)
    @api.purchase_history
    @purchases = JSON.parse @api.response_body

    total_tax, total_unit, refund_total_tax, refund_total_unit = 0.0, 0.0, 0.0, 0.0

    @print = []
    @purchases.each do |p|
      if p['number'] == params[:id]
        p['purchase_items'].each do |x|
          if x['refunded']
            refund_total_tax += x['tax'].to_f
            refund_total_unit +=  x['item_price'].to_f
          else
            total_tax += x['tax'].to_f
            total_unit = total_unit +  x['item_price'].to_f
          end
        end
        p['unit_price_taxed'] = p['unit_price'].to_f + p['tax'].to_f
        @print = p # since we already recursed the list send just the matching records
        break # we found the one we wanted so no need to continue looking
      end
    end

    @print['refund_total_unit'] = refund_total_unit
    @print['refund_total_tax'] = refund_total_tax
    @print['total_unit'] = total_unit
    @print['total_tax'] = total_tax
    render :layout => false
  end

  private

  def confirmation_email(args)
    @client = FuelSDK::Client.new({ 'client' => {'id' => EXACT_TARGET[:id],
      'secret' => EXACT_TARGET[:secret]} })

    triggered_send = {
        'CustomerKey' => args['triggered_send_id'],
        'Subscribers' => [
          {
            'EmailAddress' => args['recipient_email'],
            'SubscriberKey' => args['recipient_email'],
            'Attributes' => self.class.email_attributes(args['params'])
          }
        ],
      }
    status = @client.SendTriggeredSends([triggered_send])
   end

  def self.email_attributes(attrs)
      attrs.map { |key, value| { 'Name' => key, 'Value' => value } }
  end
end
