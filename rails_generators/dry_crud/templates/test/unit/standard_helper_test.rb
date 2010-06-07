require 'test_helper'
require 'crud_test_model'

class StandardHelperTest < ActionView::TestCase

	include StandardHelper
  include CrudTestHelper
  
  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db
	
  def format_size(obj)
    "#{f(obj.size)} chars"
  end
  
	test "labeled text as block" do
		result = labeled("label") { "value" }
		
		assert_dom_equal "<div class='labeled'><div class='caption'>label</div><div class='value'>value&nbsp;</div></div>", result
  end

  test "labeled text as content" do
    result = labeled("label", "value")
    
    assert_dom_equal "<div class='labeled'><div class='caption'>label</div><div class='value'>value&nbsp;</div></div>", result
  end
  
	test "alternate row" do
		result_1 = tr_alt { "(test row content)" }
		result_2 = tr_alt { "(test row content)" }

		assert_dom_equal "<tr class='even'>(test row content)</tr>", result_1
		assert_dom_equal "<tr class='odd'>(test row content)</tr>", result_2
	end
	
	test "format Fixnums" do
		assert_equal "0", f(0)
		assert_equal "10", f(10)
    assert_equal "10,000,000", f(10000000)    
	end
	
	test "format Floats" do
		assert_equal "1.00", f(1.0)
		assert_equal "1.20", f(1.2)
		assert_equal "3.14", f(3.14159)
	end
	
	test "format Booleans" do
		assert_equal "yes", f(true)
		assert_equal "no", f(false)
	end
	
	test "format nil" do
		assert_equal "", f(nil)
	end
	
	test "format Strings" do
		assert_equal "blah blah", f("blah blah")
 		assert_equal "&lt;injection&gt;", f("<injection>")
  end

  test "format attr with fallthrough to f" do
    assert_equal "12.23", format_attr("12.23424", :to_f)
  end
  
  test "format attr with custom format_size method" do
    assert_equal "4 chars", format_attr("abcd", :size)
  end
	
	test "empty table should render message" do
		assert_dom_equal "<div class='list'>#{NO_LIST_ENTRIES_MESSAGE}</div>", table([]) { }
	end	
	
  test "non empty table should render table" do
    assert_match(/^\<table.*\<\/table\>$/, table(['foo', 'bar']) {|t| t.attrs :size, :upcase })
  end
  
  test "captionize" do
    assert_equal "Camel Case", captionize(:camel_case)
    assert_equal "All Upper Case", captionize("all upper case")
    assert_equal "With Object", captionize("With object", Object.new)
  end
	
  test "standard form for existing entry" do
    e = crud_test_models('AAAAA')
    f = capture { standard_form(e, [:name, :children, :birthdate, :human], :class => 'special') }
    
    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="put"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text" .*?value="AAAAA"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /option selected="selected" value="1910">1910<\/option>/, f
    assert_match /option selected="selected" value="1">January<\/option>/, f
    assert_match /option selected="selected" value="1">1<\/option>/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="text" .*?value=\"1\"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /input .*?type="submit" .*?value="Save"/, f
  end
  
  test "standard form for new entry" do
    e = CrudTestModel.new
    f = capture { standard_form(e, [:name, :children, :birthdate, :human], :class => 'special') }
    
    assert_match /form .*?action="\/crud_test_models" .*?method="post"/, f
    assert_match /input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_no_match /input .*?name="crud_test_model\[name\]" .*?type="text" .*?value=/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="text"/, f
    assert_no_match /input .*?name="crud_test_model\[children\]" .*?type="text" .*?value=/, f
    assert_match /input .*?type="submit" .*?value="Save"/, f
  end
  
  
  test "standard form with errors" do
    e = crud_test_models('AAAAA')
    e.name = nil
    assert !e.valid?
   
    f = capture { standard_form(e, [:name, :children, :birthdate, :human], :class => 'special') }
    
    assert_match /form .*?action="\/crud_test_models\/#{e.id}" .*?method="post"/, f
    assert_match /input .*?name="_method" .*?type="hidden" .*?value="put"/, f
    assert_match /div class="errorExplanation"/, f
    assert_match /div class="fieldWithErrors"\>.*?\<input .*?name="crud_test_model\[name\]" .*?type="text"/, f
    assert_match /select .*?name="crud_test_model\[birthdate\(1i\)\]"/, f
    assert_match /option selected="selected" value="1910">1910<\/option>/, f
    assert_match /option selected="selected" value="1">January<\/option>/, f
    assert_match /option selected="selected" value="1">1<\/option>/, f
    assert_match /input .*?name="crud_test_model\[children\]" .*?type="text" .*?value=\"1\"/, f
    assert_match /input .*?name="crud_test_model\[human\]" .*?type="checkbox"/, f
    assert_match /input .*?type="submit" .*?value="Save"/, f
  end
  
end