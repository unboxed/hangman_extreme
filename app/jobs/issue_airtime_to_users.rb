module App

  module Jobs

    class IssueAirtimeToUsers

      def run
        # perform work here
        if RedeemWinning.pending_airtime.any?
          client = Savon.client(wsdl: api_url, open_timeout: 60, read_timeout: 60)
          RedeemWinning.pending_airtime.each do |redeem_winning|
            freepaid_refno = generate_refno(redeem_winning)
            response = client.call(:get_voucher, message: {get_voucher_in: {
                                                          user: ENV['FREEPAID_USER'],
                                                          pass: ENV['FREEPAID_PASS'],
                                                          refno: freepaid_refno,
                                                          network: network(redeem_winning),
                                                          sellvalue: "5"} })
            reply = response.body[:get_voucher_response][:reply]
            if reply[:status].to_i == 1
              redeem_winning.paid!
              AirtimeVoucher.create!(redeem_winning: redeem_winning, freepaid_refno: freepaid_refno,
                                     network: network(redeem_winning), pin: reply[:pin],
                                     sellvalue: "5", response: response.body, user: redeem_winning.user)
              redeem_winning.user.send_message("Your airtime voucher is available in the $airtime vouchers$ section.")
            else
              Airbrake.notify_or_ignore(Exception.new(reply[:message]))
            end
          end
        end
      end

      def api_url
        Rails.env.production? ? 'https://ws.freepaid.co.za/airtime/?wsdl' : 'http://pi.dynalias.net:3088/airtime/?wsdl'
      end

      def network(redeem_winning)
        {vodago_airtime: "vodacom", cell_c_airtime: "cellc", mtn_airtime: "mtn" }[redeem_winning.prize_type.to_sym]
      end

      def generate_refno(redeem_winning)
        "RW#{redeem_winning.id}T#{Time.now.strftime('%Y%m%dT%H%M')}"
      end

      def on_error(exception)
        # Optionally implement this method to interrogate any exceptions
        # raised inside the job's run method.
        Airbrake.notify_or_ignore(exception)
      end

    end

  end

end