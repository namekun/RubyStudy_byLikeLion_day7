class AskController < ApplicationController
    
    def index
        @asks = Ask.all
    end
    
    def new
      
    end
    
    def create
        a1 = Ask.new
        a1.question = params[:question]
        a1.ipaddress = request.ip
        a1.region = request.location.region
        a1.save
        redirect_to '/ask'
    end
    
    def delete
        ask = Ask.find(params[:id])
        ask.destroy
        redirect_to '/ask'
    end
    
    def edit
        @ask = Ask.find(params[:id]) 
    end
    
    def update
        ask = Ask.find(params[:id])
        ask.question = params[:question]
        ask.save
        redirect_to '/ask'
    end
    
    def show
        @ask = Ask.find(params[:id])
    end
end
