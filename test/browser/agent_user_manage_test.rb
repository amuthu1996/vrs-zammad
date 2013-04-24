# encoding: utf-8
require 'browser_test_helper'

class AgentUserManageTest < TestCase
  def test_agent_user
    customer_user_email = 'customer-test-' + rand(999999).to_s + '@example.com'
    tests = [
      {
        :name     => 'create customer',
        :action   => [
          {
            :execute => 'click',
            :css     => 'a[href="#new"]',
          },
          {
            :execute => 'click',
            :css     => 'a[href="#ticket_create/call_inbound"]',
          },
          {
            :execute => 'wait',
            :value   => 5,
          },
          {
            :execute => 'click',
            :css     => '.customer_new',
          },
          {
            :execute => 'wait',
            :value   => 2,
          },
          {
            :execute => 'set',
            :css     => '.modal input[name="firstname"]',
            :value   => 'Customer Firstname',
          },
          {
            :execute => 'set',
            :css     => '.modal input[name="lastname"]',
            :value   => 'Customer Lastname',
          },
          {
            :execute => 'set',
            :css     => '.modal input[name="email"]',
            :value   => customer_user_email,
          },
          {
            :execute => 'click',
            :css     => '.modal button',
          },
          {
            :execute => 'wait',
            :value   => 4,
          },

          # check is used is selected
          {
            :execute      => 'match',
            :css          => 'input[name="customer_id"]',
            :value        => '^[0-9].?$',
            :no_quote     => true,
            :match_result => true,
          },
          {
            :execute      => 'match',
            :css          => 'input[name="customer_id_autocompletion"]',
            :value        => 'Customer',
            :no_quote     => true,
            :match_result => true,
          },

          # call new ticket screen again
          {
            :execute => 'click',
            :css     => '.taskbar span[data-type="close"]',
          },

          # accept task close warning
          {
            :execute => 'accept',
            :element => :alert,
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :execute => 'click',
            :css     => 'a[href="#new"]',
          },
          {
            :execute => 'click',
            :css     => 'a[href="#ticket_create/call_inbound"]',
          },
          {
            :execute => 'wait',
            :value   => 2,
          },
          {
            :execute      => 'match',
            :css          => 'input[name="customer_id"]',
            :value        => '^[0-9].?$',
            :no_quote     => true,
            :match_result => false,
          },
          {
            :execute      => 'match',
            :css          => 'input[name="customer_id_autocompletion"]',
            :value        => 'Customer',
            :no_quote     => true,
            :match_result => false,
          },
          {
            :execute => 'set',
            :css     => '.ticket_create input[name="customer_id_autocompletion"]',
            :value   => customer_user_email,
          },
          {
            :execute => 'wait',
            :value   => 4,
          },
          {
            :execute => 'sendkey',
            :css     => '.ticket_create input[name="customer_id_autocompletion"]',
            :value   => :arrow_down,
          },
          {
            :execute => 'sendkey',
            :css     => '.ticket_create input[name="customer_id_autocompletion"]',
            :value   => :tab,
          },
          {
            :execute      => 'match',
            :css          => 'input[name="customer_id"]',
            :value        => '^[0-9].?$',
            :no_quote     => true,
            :match_result => true,
          },
          {
            :execute      => 'match',
            :css          => 'input[name="customer_id_autocompletion"]',
            :value        => 'Customer',
            :no_quote     => true,
            :match_result => true,
          },
        ],
      },
    ]
    browser_signle_test_with_login(tests, { :username => 'agent1@example.com' })
  end
end