class AdminChatroomsController < ApplicationController
  before_action :set_chatroom, only: [:show, :edit, :update, :destroy]
  before_action :set_admin 
  before_action :authenticate_admin!
  # GET /chatrooms
  # GET /chatrooms.json
  # GET /admins.json
  def index
    redirect_to new_chatroom_path()
  end

  # GET /conversations/1
  # GET /conversations/1.json
  def show
    # Below - Returns the chatrooms the current admin is already in.
    @current_chatrooms = current_admin.admin_chatrooms
    # Below - Returns the available chatrooms that the admin is currently not in.
    @available_chatrooms = current_admin.main_workplace.admin_chatrooms - @current_chatrooms
    @message = AdminMessage.new
    # Below - If the admin doesn't have any active chatrooms, sends them to new page. Otherswise to Show with existing conversations
    if current_admin.admin_chatrooms.empty? 
      render 'new'
    else 
      @messages = @chatroom.admin_messages.order(created_at: :desc).limit(200).reverse
    end 
    
  end

  # GET /conversations/new
  def new
    @admins = current_admin.city.admins.all
    @chatroom = AdminChatroom.new
    @chatrooms = current_admin.main_workplace.admin_chatrooms
  end

  # GET /conversations/1/edit
  def edit
    
  end

  # POST /chatrooms
  # POST /chatrooms.json
  def create
    @chatroom = current_admin.main_workplace.admin_chatrooms.build(chatroom_params)
    respond_to do |format|
      if @chatroom.save
        @chatroom_admin = @chatroom.chatroom_admins.where(admin_id: current_admin.id).first_or_create
        format.html { redirect_to chatroom_path(@chatroom), notice: 'Chatroom was successfully created.' }
        format.json { render :show, status: :created, location: @chatroom }
      else
        format.html { render :new }
        format.json { render json: @chatroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conversations/1
  # PATCH/PUT /conversations/1.json
  def update
    respond_to do |format|
      if @chatroom.update(chatroom_params)
        format.html { redirect_to @chatroom, notice: 'Chatroom was successfully updated.' }
        format.json { render :show, status: :ok, location: @chatroom }
      else
        format.html { render :edit }
        format.json { render json: @chatroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conversations/1
  # DELETE /conversations/1.json
  def destroy
    @chatroom.destroy
    respond_to do |format|
      format.html { redirect_to chatrooms_url, notice: 'Chatroom was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chatroom
      @chatroom = AdminChatroom.friendly.find(params[:id])
    end
    
    def set_admin
      @admin = current_admin
    end 
    # Never trust parameters from the scary internet, only allow the white list through.
    def chatroom_params
      params.require(:admin_chatroom).permit(:name, :description)
    end
end
