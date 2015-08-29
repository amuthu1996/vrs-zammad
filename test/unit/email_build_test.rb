# encoding: utf-8
require 'test_helper'

class EmailBuildTest < ActiveSupport::TestCase
  test 'document complete check' do

    html   = '<b>test</b>'
    result = Channel::EmailBuild.html_complete_check( html )

    assert( result =~ /^<\!DOCTYPE/, 'test 1')
    assert( result !~ /^.+?<\!DOCTYPE/, 'test 1')
    assert( result =~ /<html>/, 'test 1')
    assert( result =~ /font-family/, 'test 1')
    assert( result =~ %r{<b>test</b>}, 'test 1')

    html   = 'invalid <!DOCTYPE html><html><b>test</b></html>'
    result = Channel::EmailBuild.html_complete_check( html )

    assert( result !~ /^<\!DOCTYPE/, 'test 2')
    assert( result =~ /^.+?<\!DOCTYPE/, 'test 2')
    assert( result =~ /<html>/, 'test 2')
    assert( result !~ /font-family/, 'test 2')
    assert( result =~ %r{<b>test</b>}, 'test 2')

  end

  test 'html email + attachment check' do
    html = '<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <head>
  <body style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;">
    <div>&gt; Welcome!</div><div>&gt;</div><div>&gt; Thank you for installing Zammad. äöüß</div><div>&gt;</div>
  </body>
</html>'
    mail = Channel::EmailBuild.build(
      from: 'sender@example.com',
      to: 'recipient@example.com',
      body: html,
      content_type: 'text/html',
      attachments: [
        {
          'Mime-Type'    => 'image/png',
          :content      => 'xxx',
          :filename     => 'somename.png',
        },
      ],
    )

    should = '> Welcome!
>
> Thank you for installing Zammad. äöüß
>'
    assert_equal( should, mail.text_part.body.to_s )
    assert_equal( html, mail.html_part.body.to_s )

    parser = Channel::EmailParser.new
    data = parser.parse( mail.to_s )

    # check body
    assert_equal( should, data[:body] )

    # check count of attachments, only 2, because 3 part is text message and is already in body
    assert_equal( 2, data[:attachments].length )

    # check attachments
    if data[:attachments]
      data[:attachments].each { |attachment|
        if attachment[:filename] == 'message.html'
          assert_equal( nil, attachment[:preferences]['Content-ID'] )
          assert_equal( true, attachment[:preferences]['content-alternative'] )
          assert_equal( 'text/html', attachment[:preferences]['Mime-Type'] )
          assert_equal( 'UTF-8', attachment[:preferences]['Charset'] )
        elsif attachment[:filename] == 'somename.png'
          assert_equal( nil, attachment[:preferences]['Content-ID'] )
          assert_equal( nil, attachment[:preferences]['content-alternative'] )
          assert_equal( 'image/png', attachment[:preferences]['Mime-Type'] )
          assert_equal( 'UTF-8', attachment[:preferences]['Charset'] )
        else
          assert( false, "invalid attachment, should not be there, #{attachment.inspect}" )
        end
      }
    end
  end

  test 'plain email + attachment check' do
    text = '> Welcome!
>
> Thank you for installing Zammad. äöüß
>'
    mail = Channel::EmailBuild.build(
      from: 'sender@example.com',
      to: 'recipient@example.com',
      body: text,
      attachments: [
        {
          'Mime-Type'    => 'image/png',
          :content      => 'xxx',
          :filename     => 'somename.png',
        },
      ],
    )

    should = '> Welcome!
>
> Thank you for installing Zammad. äöüß
>'
    assert_equal( should, mail.text_part.body.to_s )
    assert_equal( nil, mail.html_part )

    parser = Channel::EmailParser.new
    data = parser.parse( mail.to_s )

    # check body
    assert_equal( should, data[:body] )

    # check count of attachments, 2
    assert_equal( 1, data[:attachments].length )

    # check attachments
    if data[:attachments]
      data[:attachments].each { |attachment|
        if attachment[:filename] == 'somename.png'
          assert_equal( nil, attachment[:preferences]['Content-ID'] )
          assert_equal( nil, attachment[:preferences]['content-alternative'] )
          assert_equal( 'image/png', attachment[:preferences]['Mime-Type'] )
          assert_equal( 'UTF-8', attachment[:preferences]['Charset'] )
        else
          assert( false, "invalid attachment, should not be there, #{attachment.inspect}" )
        end
      }
    end
  end

  test 'plain email + without attachment check' do
    text = '> Welcome!
>
> Thank you for installing Zammad. äöüß
>'
    mail = Channel::EmailBuild.build(
      from: 'sender@example.com',
      to: 'recipient@example.com',
      body: text,
    )

    should = '> Welcome!
>
> Thank you for installing Zammad. äöüß
>'
    assert_equal( should, mail.body.to_s )
    assert_equal( nil, mail.html_part )

    parser = Channel::EmailParser.new
    data = parser.parse( mail.to_s )

    # check body
    assert_equal( should, data[:body] )

    # check count of attachments, 0
    assert_equal( 0, data[:attachments].length )

  end

end