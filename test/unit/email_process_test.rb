# encoding: utf-8
require 'test_helper'
 
class EmailProcessTest < ActiveSupport::TestCase
  test 'process' do
    files = [
      {
        :data => 'From: me@example.com
To: customer@example.com
Subject: some subject

Some Text',
        :success => true,
      },
      {
        :data => 'From: me@example.com
To: customer@example.com
Subject: some subject
X-Zammad-Ignore: true

Some Text',
        :success => false,
      },
      {
        :data => 'From: me@example.com
To: customer@example.com
Subject: some subject
X-Zammad-Priority: 3 high
X-Zammad-Article-Sender: system
x-Zammad-Article-Type: phone

Some Text',
        :success => true,
        :result => {
          0 => {
            :ticket_priority       => '3 high',
          },
          1 => {
            :ticket_article_sender => 'System',
            :ticket_article_type   => 'phone',
          },
        },
      },
    ]

    files.each { |file|
      parser = Channel::EmailParser.new
      result = parser.process( { :trusted => true }, file[:data] )
      if file[:success] && result[1]
        assert( true )
        if file[:result]
          [ 0, 1, 2 ].each { |level|
            if file[:result][level]
              file[:result][level].each { |key, value|
                assert_equal( result[level].send(key).name, value.to_s)
              }
            end
          }
        end
      elsif !file[:success] && result == true
        assert( true )
      elsif !file[:success] && result[1]
        assert( false, 'ticket should not be created' )
      else
        assert( false, 'UNKNOWN!' )
      end
    }
  end
end