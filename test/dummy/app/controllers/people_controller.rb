class PeopleController < ApplicationController
  def index
  	setup_pagination
                @people = Person.all
                  .paginate(per_page: @per_page, page: @page)
  end

  def new
  	@person = Person.new
  end

  def create
  	@person = Person.new(person_params)
    if @person.save
      flash[:success] = "Created Person successfully"
      redirect_to redir_url
    else
      flash_alert(@person)
      render :new
    end
  end

  def edit
  	@person = Person.find(params[:id])
  end

  def update
  	@person = Person.find(params[:id])
    if @person.update_attributes(person_params)
      flash[:success] = "Updated Person successfully"
      redirect_to redir_url
    else
      flash_alert(@person)
      render :edit
    end
  end

  def destroy
  	@person = Person.find(params[:id])
    @person.destroy
  end

	private
	def person_params
    params.required(:person).permit([:first_name, :last_name, :email, :title, :dob, :is_manager])
  end
end
