class IssueAirtimeToUsers < IssueWinningToUser

  def redeem(redeem_winning)
    # perform work here
    freepaid_refno = generate_refno(redeem_winning)
    sellvalue = (redeem_winning.prize_amount / 100).to_s
    voucher_network = network(redeem_winning)
    pin, response_body = create_voucher_pin(freepaid_refno, voucher_network, sellvalue)
    redeem_winning.paid!
    AirtimeVoucher.create!(redeem_winning: redeem_winning, freepaid_refno: freepaid_refno, network: voucher_network,
                           pin: pin, sellvalue: sellvalue, response: response_body, user: redeem_winning.user)
    redeem_winning.user.send_message("Your airtime voucher is available in the $airtime vouchers$ section.")
  end

  private

  def api_url
    Rails.env.production? ? 'https://ws.freepaid.co.za/airtime/?wsdl' : 'http://pi.dynalias.net:3088/airtime/?wsdl'
  end

  def network(redeem_winning)
    {vodago_airtime: "vodacom",
     cell_c_airtime: "cellc",
     mtn_airtime: "mtn",
     heita_airtime: "heita",
     virgin_airtime: "branson"}[redeem_winning.prize_type.to_sym]
  end

  def generate_refno(redeem_winning)
    "RW#{redeem_winning.id}T#{Time.now.strftime('%Y%m%dT%H%M')}"
  end

  def create_voucher_pin(freepaid_refno, network, sellvalue)
    client = Savon.client(wsdl: api_url, open_timeout: 180, read_timeout: 180,
                          logger: Rails.logger, log_level: Rails.configuration.log_level, log: false)
    response = client.call(:get_voucher, message: {get_voucher_in: {
        user: ENV['FREEPAID_USER'],
        pass: ENV['FREEPAID_PASS'],
        refno: freepaid_refno,
        network: network,
        sellvalue: sellvalue} })
    reply = response.body[:get_voucher_response][:reply]
    if reply[:status].to_i != 1
      raise(reply[:message])
    end
    return reply[:pin], response.body
  end


end
