# encoding: utf-8
require 'browser_test_helper'

class AaaGettingStartedTest < TestCase
  def test_getting_started
    tests = [
      {
        :name     => 'start',
        :instance => browser_instance,
        :url      => browser_url + '/#getting_started',
        :action   => [
          {
            :execute => 'wait',
            :value   => 1,
          },
          {
            :execute => 'check',
            :css     => '#form-master',
            :result  => true,
          },
        ],
      },
      {
        :name     => 'getting started',
        :action   => [
          {
            :execute => 'set',
            :css     => 'input[name="firstname"]',
            :value   => 'Test Master',
          },
          {
            :execute => 'set',
            :css     => 'input[name="lastname"]',
            :value   => 'Agent',
          },
          {
            :execute => 'set',
            :css     => 'input[name="email"]',
            :value   => 'master@example.com',
          },
          {
            :execute => 'set',
            :element => :text_field,
            :css     => 'input[name="password"]',
            :value   => 'test1234äöüß',
          },
          {
            :execute => 'set',
            :css     => 'input[name="password_confirm"]',
            :value   => 'test1234äöüß',
          },
          {
            :execute => 'click',
            :css     => '#form-master button[type="submit"]',
          },
          {
            :execute => 'wait',
            :value   => 5,
          },
          {
            :execute => 'check',
            :css     => '#login',
            :result  => false,
          },
          {
            :execute => 'check',
            :element => :url,
            :result  => '#getting_started',
          },

          # check action
          {
            :execute      => 'match',
            :css          => 'body',
            :value        => 'Invite Agents',
            :match_result => true,
          },
        ],
      },
    ]
    browser_single_test(tests)
  end
end