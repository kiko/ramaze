#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

testcase_requires 'og', 'glue/timestamped'

class Entry
  attr_accessor :title, String
end

class EntryTimestamped
  attr_accessor :title, String
  is Timestamped
end

class EntryDated
  attr_accessor :date, Date
end

# catches all the stuff Og sends to Logger,
# i wished on could mute it otherwise

Logger.send(:class_variable_set, "@@global_logger", Ramaze::Informer.new)

Og.start :destroy => true

class TCFormHelperEntryController < Ramaze::Controller
  helper :form

  def index
    'FormHelper Entry'
  end

  def form_with_submit
    form Entry
  end

  def form_without_submit
    form Entry, :submit => false
  end

  def form_with_title
    form Entry, :title => 'Title'
  end

  def form_without_title
    form Entry, :title => false
  end

  def form_with_oid
    form Entry, :deny => nil
  end
end

class TCFormHelperEntryTimestampedController < Ramaze::Controller
  helper :form

  def index
    "FormHelper EntryTimestamped"
  end

  def form_with_submit
    form EntryTimestamped
  end
end

class TCFormHelperEntryDatedController < Ramaze::Controller
  helper :form

  def index
    "FormHelper Dated"
  end

  def form_with_submit
    form EntryDated
  end
end

context "FormHelper" do
  context "Entry" do
    ramaze :mapping => {'/entry' => TCFormHelperEntryController}

    specify "testrun" do
      get('/entry/').should == 'FormHelper Entry'
    end

    specify "with submit" do
      get('/entry/form_with_submit').should ==
        %{title: <input type="text" name="title" value="" /><br />\n<input type="submit" />}
    end

    specify "without submit" do
      get('/entry/form_without_submit').should ==
        %{title: <input type="text" name="title" value="" />}
    end

    specify "with title" do
      get('/entry/form_with_title').should ==
        %{Title: <input type="text" name="title" value="" /><br />\n<input type="submit" />}
    end

    specify "without title" do
      get('/entry/form_without_title').should ==
        %{<input type="text" name="title" value="" /><br />\n<input type="submit" />}
    end

    specify "with oid" do
      get('/entry/form_with_oid').should ==
        %{title: <input type="text" name="title" value="" /><br />\noid: <input type="text" name="oid" value="0" /><br />\n<input type="submit" />}
    end

    context "EntryTimestamped" do
      ramaze :fake_start => true, :mapping => {'/entry_timestamped' => TCFormHelperEntryTimestampedController}

      specify "testrun" do
        get('/entry_timestamped/').should == "FormHelper EntryTimestamped"
      end

      specify "with submit" do
        get('/entry_timestamped/form_with_submit').should ==
          "title: <input type=\"text\" name=\"title\" value=\"\" /><br />\n<input type=\"submit\" />"
      end
    end

    context "EntryDated" do
      ramaze :fake_start => true, :mapping => {'/entry_dated' => TCFormHelperEntryDatedController}

      specify "testrun" do
        get('/entry_dated').should ==
          "FormHelper Dated"
      end

      specify "with submit" do
        result = get('/entry_dated/form_with_submit')
        result.should =~ /date\[day\]/
        result.should =~ /date\[month\]/
        result.should =~ /date\[year\]/
        result.should =~ /<input type="submit" \/>/
      end
    end
  end
end
