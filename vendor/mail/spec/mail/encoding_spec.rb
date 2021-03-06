# encoding: utf-8 
require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'spec_helper')

describe "mail encoding" do

  it "should allow you to assign a mail wide charset" do
    mail = Mail.new
    mail.charset = 'utf-8'
    mail.charset.should == 'utf-8'
  end
  
  describe "using default encoding" do
    it "should allow you to send in unencoded strings to fields and encode them" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.subject = "This is あ string"
      result = "Subject: This =?UTF8?Q?is_=E3=81=82=?= string\r\n"
      mail[:subject].encoded.gsub("UTF-8", "UTF8").should == result
    end

    it "should allow you to send in unencoded strings to address fields and encode them" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.to = "Mikel Lindsああr <mikel@test.lindsaar.net>"
      result = "To: Mikel =?UTF-8?B?TGluZHPjgYLjgYJy?= <mikel@test.lindsaar.net>\r\n"
      mail[:to].encoded.should == result
    end

    it "should allow you to send in unencoded strings to address fields and encode them" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.to = "あdあ <ada@test.lindsaar.net>"
      result = "To: =?UTF-8?B?44GCZOOBgg==?= <ada@test.lindsaar.net>\r\n"
      mail[:to].encoded.should == result
    end

    it "should allow you to send in multiple unencoded strings to address fields and encode them" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.to = ["Mikel Lindsああr <mikel@test.lindsaar.net>", "あdあ <ada@test.lindsaar.net>"]
      result = "To: Mikel =?UTF-8?B?TGluZHPjgYLjgYJy?= <mikel@test.lindsaar.net>, \r\n\t=?UTF-8?B?44GCZOOBgg==?= <ada@test.lindsaar.net>\r\n"
      mail[:to].encoded.should == result
    end

    it "should allow you to send unquoted non us-ascii strings, with spaces in them" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.to = ["Foo áëô îü <extended@example.net>"]
      result = "To: Foo =?UTF-8?B?w6HDq8O0?= =?UTF-8?B?IMOuw7w=?= <extended@example.net>\r\n"
      mail[:to].encoded.should == result
    end

    it "should allow you to send in multiple unencoded strings to any address field" do
      mail = Mail.new
      mail.charset = 'utf-8'
      ['To', 'From', 'Cc', 'Reply-To'].each do |field|
        mail.send("#{field.downcase.gsub("-", '_')}=", ["Mikel Lindsああr <mikel@test.lindsaar.net>", "あdあ <ada@test.lindsaar.net>"])
        result = "#{field}: Mikel =?UTF-8?B?TGluZHPjgYLjgYJy?= <mikel@test.lindsaar.net>, \r\n\t=?UTF-8?B?44GCZOOBgg==?= <ada@test.lindsaar.net>\r\n"
        mail[field].encoded.should == result
      end
    end
    
    it "should handle groups" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.to = "test1@lindsaar.net, group: test2@lindsaar.net, me@lindsaar.net;"
      result = "To: test1@lindsaar.net, \r\n\tgroup: test2@lindsaar.net, \r\n\tme@lindsaar.net;\r\n"
      mail[:to].encoded.should == result
    end

    it "should handle groups with funky characters" do
      mail = Mail.new
      mail.charset = 'utf-8'
      mail.to = '"Mikel Lindsああr" <test1@lindsaar.net>, group: "あdあ" <test2@lindsaar.net>, me@lindsaar.net;'
      result = "To: =?UTF-8?B?TWlrZWwgTGluZHPjgYLjgYJy?= <test1@lindsaar.net>, \r\n\tgroup: =?UTF-8?B?44GCZOOBgg==?= <test2@lindsaar.net>, \r\n\tme@lindsaar.net;\r\n"
      mail[:to].encoded.should == result
    end

    describe "quouting token safe chars" do
    
      it "should not quote the display name if unquoted" do
        mail = Mail.new
        mail.charset = 'utf-8'
        mail.to = 'Mikel Lindsaar <mikel@test.lindsaar.net>'
        mail[:to].encoded.should == %{To: Mikel Lindsaar <mikel@test.lindsaar.net>\r\n}
      end

      it "should not quote the display name if already quoted" do
        mail = Mail.new
        mail.charset = 'utf-8'
        mail.to = '"Mikel Lindsaar" <mikel@test.lindsaar.net>'
        mail[:to].encoded.should == %{To: Mikel Lindsaar <mikel@test.lindsaar.net>\r\n}
      end

    end
    
    describe "quoting token unsafe chars" do
      it "should quote the display name" do
        pending
        mail = Mail.new
        mail.charset = 'utf-8'
        mail.to = "Mikel @ me Lindsaar <mikel@test.lindsaar.net>"
        mail[:to].encoded.should == %{To: "Mikel @ me Lindsaar" <mikel@test.lindsaar.net>\r\n}
      end

      it "should preserve quotes needed from the user and not double quote" do
        mail = Mail.new
        mail.charset = 'utf-8'
        mail.to = %{"Mikel @ me Lindsaar" <mikel@test.lindsaar.net>}
        mail[:to].encoded.should == %{To: "Mikel @ me Lindsaar" <mikel@test.lindsaar.net>\r\n}
      end
    end
  end

  describe "specifying an email wide encoding" do
    it "should allow you to send in unencoded strings to fields and encode them" do
      mail = Mail.new
      mail.charset = 'ISO-8859-1'
      subject = "This is あ string"
      subject.force_encoding('ISO8859-1') if RUBY_VERSION > '1.9'
      mail.subject = subject
      result = mail[:subject].encoded
      string = "Subject: This =?ISO-8859-1?Q?is_=E3=81=82=?= string\r\n"
      if RUBY_VERSION > '1.9'
        string.force_encoding('ISO8859-1')
        result.force_encoding('ISO8859-1')
      end
      result.should == string
    end

    it "should allow you to send in unencoded strings to address fields and encode them" do
      mail = Mail.new
      mail.charset = 'ISO-8859-1'
      string = "Mikel Lindsああr <mikel@test.lindsaar.net>"
      string.force_encoding('ISO8859-1') if RUBY_VERSION > '1.9'
      mail.to = string
      result = mail[:to].encoded
      string = "To: Mikel =?ISO-8859-1?B?TGluZHPjgYLjgYJy?= <mikel@test.lindsaar.net>\r\n"
      if RUBY_VERSION > '1.9'
        string.force_encoding('ISO8859-1')
        result.force_encoding('ISO8859-1')
      end
      result.should == string
    end

    it "should allow you to send in multiple unencoded strings to address fields and encode them" do
      mail = Mail.new
      mail.charset = 'ISO-8859-1'
      array = ["Mikel Lindsああr <mikel@test.lindsaar.net>", "あdあ <ada@test.lindsaar.net>"]
      array.map! { |a| a.force_encoding('ISO8859-1') } if RUBY_VERSION > '1.9'
      mail.to = array
      result = mail[:to].encoded
      string = "To: Mikel =?ISO-8859-1?B?TGluZHPjgYLjgYJy?= <mikel@test.lindsaar.net>, \r\n\t=?ISO-8859-1?B?44GCZOOBgg==?= <ada@test.lindsaar.net>\r\n"
      if RUBY_VERSION > '1.9'
        string.force_encoding('ISO8859-1')
        result.force_encoding('ISO8859-1')
      end
      result.should == string
    end

    it "should allow you to send in multiple unencoded strings to any address field" do
      mail = Mail.new
      array = ["Mikel Lindsああr <mikel@test.lindsaar.net>", "あdあ <ada@test.lindsaar.net>"]
      array.map! { |a| a.force_encoding('ISO8859-1') } if RUBY_VERSION > '1.9'
      mail.charset = 'ISO-8859-1'
      ['To', 'From', 'Cc', 'Reply-To'].each do |field|
        mail.send("#{field.downcase.gsub("-", '_')}=", array)
        string = "#{field}: Mikel =?ISO-8859-1?B?TGluZHPjgYLjgYJy?= <mikel@test.lindsaar.net>, \r\n\t=?ISO-8859-1?B?44GCZOOBgg==?= <ada@test.lindsaar.net>\r\n"
        result = mail[field].encoded
        if RUBY_VERSION > '1.9'
          string.force_encoding('ISO8859-1')
          result.force_encoding('ISO8859-1')
        end
        result.should == string
      end
    end
  end

  it "should let you define a charset per part" do
    mail = Mail.new
    part = Mail::Part.new
    part.content_type = "text/html"
    part.charset = "ISO-8859-1"
    part.body = "blah"
    mail.add_part(part)
    mail.parts[0].content_type.should == "text/html; charset=ISO-8859-1"
  end

end