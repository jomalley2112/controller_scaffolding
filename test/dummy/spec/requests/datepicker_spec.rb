require 'spec_helper'

describe "Datepicker", :js => true do
  # @g_cmd_str = 
  #   'rails g controller_scaffolding schedule index new create edit update destroy' \
  #   ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper --skip-datepicker' 
  # before(:each) do
    
  # end

  describe "when generator is invoked with --skip-datepicker option" do
    before(:all) do
      %x(#{gen_cmd("generate", "--skip-datepicker")})
      Rails.application.reload_routes!
    end

    after(:all) do
      %x(#{gen_cmd("destroy", "--skip-datepicker")})
    end

    describe "No jQuery datepicker objects are attached to any inputs" do
      before(:each) do
        visit(new_schedule_path)
      end
      describe "rails date input" do
        it "is attached to birthday field" do
          page.should have_selector("select#schedule_birthday_1i")
        end
        
      end
      describe "rails time input" do
        it "is attached to breakfast field" do
          page.should have_selector("select#schedule_breakfast_4i")
        end
      end
      describe "rails datetime input" do
        it "is attached to appointment field" do
          page.should have_selector("select#schedule_appointment_1i")
        end
      end
    end
    
  end

  describe "when generator is invoked with no --skip-datepicker option specified" do
    before(:all) do
      %x(#{gen_cmd("generate")})
      Rails.application.reload_routes!
      
    end

    after(:all) do
      %x(#{gen_cmd("destroy")})
    end

    describe "It has jQuery picker objects attached to any date, time and datetime inputs" do
      before(:each) do
        visit(new_schedule_path)
      end
      describe "datepicker" do
        it "is diplayed when birthday field receives the focus" do
          find("input#birthday").click
          page.should have_selector("div#ui-datepicker-div")
        end
        
      end
      describe "timepicker" do
        it "is diplayed when breakfast field receives the focus" do
          find("input#breakfast").click
          page.should have_selector("div#ui-datepicker-div")
        end
      end
      describe "datetimepicker" do
        it "is diplayed when appointment field receives the focus" do
          find("input#appointment").click
          page.should have_selector("div#ui-datepicker-div")
        end
      end
    end
  end



	private
  def gen_cmd(invoke="generate", append_to_cmd_str="")
    cmd_str = "rails #{invoke} controller_scaffolding schedules index new create edit update destroy"
    cmd_str << " --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper #{append_to_cmd_str}"
    puts "\n#{cmd_str}"
    cmd_str
  end


end