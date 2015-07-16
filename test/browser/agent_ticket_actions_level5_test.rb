# encoding: utf-8
require 'browser_test_helper'

class AgentTicketActionLevel5Test < TestCase
  def test_I
    random = 'text_module_test_' + rand(99999999).to_s
    random2 = 'text_module_test_' + rand(99999999).to_s

    # user
    tests = [
      {
        :name     => 'add #1',
        :action   => [
          {
            :execute => 'close_all_tasks',
          },
          {
            :execute => 'click',
            :css     => 'a[href="#manage"]',
          },
          {
            :execute => 'click',
            :css     => 'a[href="#manage/text_modules"]',
          },
          {
            :execute => 'click',
            :css     => 'a[data-type="new"]',
          },
          {
            :execute => 'set',
            :css     => '.modal input[name=name]',
            :value   => 'some name' + random,
          },
          {
            :execute => 'set',
            :css     => '.modal input[name="keywords"]',
            :value   => random,
          },
          {
            :execute => 'set',
            :css     => '.modal textarea[name="content"]',
            :value   => 'some content' + random,
          },
          {
            :execute => 'click',
            :css     => '.modal button.submit',
          },
          {
            :execute => 'wait',
            :value   => 3,
          },
          {
            :execute      => 'match',
            :css          => 'body',
            :value        => random,
            :match_result => true,
          },
        ],
      },
      {
        :name     => 'add #2',
        :action   => [
          {
            :execute => 'click',
            :css     => 'a[href="#manage"]',
          },
          {
            :execute => 'click',
            :css     => 'a[href="#manage/text_modules"]',
          },
          {
            :execute => 'click',
            :css     => 'a[data-type="new"]',
          },
          {
            :execute => 'set',
            :css     => '.modal input[name=name]',
            :value   => 'some name' + random2,
          },
          {
            :execute => 'set',
            :css     => '.modal input[name="keywords"]',
            :value   => random2,
          },
          {
            :execute => 'set',
            :css     => '.modal textarea[name="content"]',
            :value   => 'some content' + random2,
          },
          {
            :execute => 'click',
            :css     => '.modal button.submit',
          },
          {
            :execute => 'wait',
            :value   => 3,
          },
          {
            :execute      => 'match',
            :css          => 'body',
            :value        => random2,
            :match_result => true,
          },
        ],
      },
      {
        :name     => 'verify usage',
        :action   => [
          {
            :execute => 'click',
            :css     => 'a[href="#new"]',
          },
          {
            :execute => 'click',
            :css     => 'a[href="#ticket/create/call_outbound"]',
          },
          {
            :execute => 'wait',
            :value   => 2,
          },
          {
            :execute => 'set',
            :css     => '.active textarea[name=body]',
            :value   => '::' + random,
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :execute      => 'match',
            :css          => 'body',
            :value        => random,
            :match_result => true,
          },
          {
            :execute => 'click',
            :css     => '.-sew-list-item.selected',
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :execute      => 'match',
            :css          => '.active textarea[name=body]',
            :value        => 'some content' + random,
            :match_result => true,
          },
        ],
      },
    ]
    browser_signle_test_with_login(tests, { :username => 'master@example.com' })
  end
  def test_II
    random = 'text_II_module_test_' + rand(99999999).to_s

    user_rand = rand(99999999).to_s
    login     = 'agent-text-module-' + user_rand
    firstname = 'Text' + user_rand
    lastname  = 'Module' + user_rand
    email     = 'agent-text-module-' + user_rand + '@example.com'
    password  = 'agentpw'

    # user
    tests = [
      {
        :name     => 'start',
        :instance1 => browser_instance,
        :instance2 => browser_instance,
        :instance1_username => 'master@example.com',
        :instance1_password => 'test',
        :instance2_username => 'agent1@example.com',
        :instance2_password => 'test',
        :action   => [
          # create ticket
          {
            :where   => :instance2,
            :execute => 'close_all_tasks',
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.taskbar-new a[href="#new"]',
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.taskbar-new a[href="#ticket/create/call_inbound"]',
          },
          {
            :where   => :instance2,
            :execute => 'set',
            :css     => '.active input[name=title]',
            :value   => 'A',
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.taskbar-new a[href="#new"]',
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.taskbar-new a[href="#ticket/create/call_outbound"]',
          },
          {
            :where   => :instance2,
            :execute => 'set',
            :css     => '.active input[name=title]',
            :value   => 'B',
          },

          # create new text module
          {
            :where   => :instance1,
            :execute => 'click',
            :css     => 'a[href="#manage"]',
          },
          {
            :where   => :instance1,
            :execute => 'click',
            :css     => 'a[href="#manage/text_modules"]',
          },
          {
            :where   => :instance1,
            :execute => 'click',
            :css     => 'a[data-type="new"]',
          },
          {
            :where   => :instance1,
            :execute => 'set',
            :css     => '.modal input[name=name]',
            :value   => 'some name' + random,
          },
          {
            :where   => :instance1,
            :execute => 'set',
            :css     => '.modal input[name="keywords"]',
            :value   => random,
          },
          {
            :where   => :instance1,
            :execute => 'set',
            :css     => '.modal textarea[name="content"]',
            :value   => 'some content <%= @ticket.customer.lastname %>' + random,
          },
          {
            :where   => :instance1,
            :execute => 'click',
            :css     => '.modal button.submit',
          },
          {
            :execute => 'wait',
            :value   => 3,
          },
          {
            :where   => :instance1,
            :execute      => 'match',
            :css          => 'body',
            :value        => random,
            :match_result => true,
          },


        ],
      },

      # create user
      {
        :name     => 'create user',
        :action   => [
          {
            :where      => :instance1,
            :execute    => 'create_user',
            :login      => login,
            :firstname  => firstname,
            :lastname   => lastname,
            :email      => email,
            :password   => password,
          },
        ],
      },
      {
        :name     => 'check if text module exists in instance2, for ready to use',
        :action   => [
          {
            :execute => 'wait',
            :value   => 4,
          },
          {
            :where   => :instance2,
            :execute => 'set',
            :css     => '.active textarea[name=body]',
            :value   => '::' + random,
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => 'body',
            :value        => random,
            :match_result => true,
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.-sew-list-item.selected',
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => '.active textarea[name=body]',
            :value        => 'some content ' + random,
            :match_result => true,
          },
          {
            :execute => 'wait',
            :value   => 3,
          },
          {
            :where   => :instance2,
            :execute => 'set',
            :css     => '.active .ticket-create input[name="customer_id_autocompletion"]',
            :value   => 'nicole',
          },
          {
            :execute => 'wait',
            :value   => 4,
          },
          {
            :where   => :instance2,
            :execute => 'sendkey',
            :css     => '.active .ticket-create input[name="customer_id_autocompletion"]',
            :value   => :arrow_down,
          },
          {
            :where   => :instance2,
            :execute => 'sendkey',
            :css     => '.active .ticket-create input[name="customer_id_autocompletion"]',
            :value   => :tab,
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where   => :instance2,
            :execute => 'set',
            :css     => '.active textarea[name=body]',
            :value   => '::' + random,
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.-sew-list-item.selected',
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => '.active textarea[name=body]',
            :value        => 'some content Braun' + random,
            :match_result => true,
          },
        ],
      },
      {
        :name     => 'verify zoom',
        :action   => [

          {
            :where   => :instance1,
            :execute => 'click',
            :css     => 'a[href="#manage"]',
          },

          # create ticket
          {
            :where   => :instance2,
            :execute => 'create_ticket',
            :group   => 'Users',
            :subject => 'some subject 123äöü',
            :body    => 'some body 123äöü',
          },

          # check ticket
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => '.active div.ticket-article',
            :value        => 'some body 123äöü',
            :match_result => true,
          },

          # check ticket zoom
          {
            :execute => 'wait',
            :value   => 4,
          },
          {
            :where    => :instance2,
            :execute => 'set',
            :css     => '.active textarea[name=body]',
            :value   => 'test',
          },
          {
            :execute => 'wait',
            :value   => 2,
          },
          {
            :where    => :instance2,
            :execute => 'set',
            :css     => '.active textarea[name=body]',
            :value   => '::' + random,
          },
          {
            :execute => 'wait',
            :value   => 0.5,
          },
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => 'body',
            :value        => random,
            :match_result => true,
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.-sew-list-item.selected',
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => '.active textarea[name=body]',
            :value        => 'some content Braun' + random,
            :match_result => true,
          },
        ],
      },
      {
        :name     => 'change customer',
        :action   => [

          {
            :where   => :instance1,
            :execute => 'click',
            :css     => 'a[href="#manage"]',
          },

          # create ticket
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.active .action button',
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.active .action [data-type="customer"]',
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where   => :instance2,
            :execute => 'set',
            :css     => '#form-customer input[name="customer_id_autocompletion"]',
            :value   => firstname,
          },
          {
            :execute => 'wait',
            :value   => 4,
          },
          {
            :where   => :instance2,
            :execute => 'sendkey',
            :css     => '#form-customer input[name="customer_id_autocompletion"]',
            :value   => :arrow_down,
          },
          {
            :where   => :instance2,
            :execute => 'sendkey',
            :css     => '#form-customer input[name="customer_id_autocompletion"]',
            :value   => :tab,
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.modal-content [type="submit"]',
          },
          {
            :where   => :instance2,
            :execute => 'wait',
            :value   => 4,
          },
          {
            :where    => :instance2,
            :execute => 'set',
            :css     => '.active textarea[name=body]',
            :value   => '::' + random,
          },
          {
            :execute => 'wait',
            :value   => 0.5,
          },
#          {
#            :where        => :instance2,
#            :execute      => 'match',
#            :css          => 'body',
#            :value        => random,
#            :match_result => true,
#          },
          {
            :where   => :instance2,
            :execute => 'click',
            :css     => '.-sew-list-item.selected',
          },
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :where        => :instance2,
            :execute      => 'match',
            :css          => '.active textarea[name=body]',
            :value        => 'some content ' + lastname,
            :match_result => true,
          },
          {
            :execute => 'wait',
            :value   => 2,
          },
        ],
      },


    ]
    browser_double_test(tests)
  end
end